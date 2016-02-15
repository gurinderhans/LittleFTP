//
//  LFFilesTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa
import FTPManager

struct TableViewColIds {
    static let NAME_ID = "NameCol"
    static let DATE_MOD_ID = "ModDateCol"
}

class LFFilesTableViewController: NSObject, NSTableViewDelegate, NSTableViewDataSource, FTPManagerDelegate {
    
    @IBOutlet weak var filesListTableView: NSTableView!
    
    // these two views reside in the toolbar in the center
    var filenameLabel: NSTextView?
    var filenameProgress: NSProgressIndicator?
    
    private var _filesList = [LFFile]()
    var filesList: [LFFile] {
        get { return _filesList }
        set(newArray) {
            _filesList = newArray.sort({ (a, b) -> Bool in
                return a.isFolder
            })
        }
    }
    
    var currentPath: NSURL!
    let filesQueue = LFQueue<NSURL>()
    var uploaderIsLooping:Bool = false
    
    override init() {
        super.init()
        
        LFServerManager.ftpManager.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "listServer:", name: "listServer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "navigationChanged:", name: "navigationChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "progressAreaReady:", name: "progressAreaReady", object: nil)
    }
    
    override func awakeFromNib() {
        filesListTableView.target = self
        filesListTableView.doubleAction = "doubleClickRow:"
        filesListTableView.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    // MARK: - Selector methods
    
    func progressAreaReady(sender: AnyObject!) {
        if let progressViews = sender.object as? [NSView] {
            filenameLabel = progressViews[0] as? NSTextView
            filenameProgress = progressViews[1] as? NSProgressIndicator
        }
    }
    
    func navigationChanged(sender: AnyObject!) {
        if let code = sender.object as? Int {
            if code == 0 {
                // BACK
                // TODO: nullity checks
                let prevPath = currentPath.URLByDeletingLastPathComponent?.absoluteString
                LFServerManager.activeServer?.destination = prevPath
                fetchDir(prevPath!, onComplete: nil) // TOOD: onComplete set currentPath to new path
            } else if code == 1 {
                // FORWARD
                print("forward")
            }
        }
    }
    
    func doubleClickRow(sender: AnyObject?) {
        print("dbl clicked row")
        // FIXME: - index out of range error
        if filesList[filesListTableView.clickedRow].isFolder == true {
            let path = currentPath.URLByAppendingPathComponent(filesList[filesListTableView.clickedRow].name, isDirectory: filesList[filesListTableView.clickedRow].isFolder).absoluteString
            LFServerManager.activeServer?.destination = path
            fetchDir(path, onComplete: nil)
        }
    }
    
    // MARK: - NSTableViewDelegate & NSTableViewDataSource methods
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == TableViewColIds.NAME_ID {
            // TODO: differentiate between file & folder
            let cell = tableView.makeViewWithIdentifier("ServerFileNameCell", owner: self) as! LFFileNameItemCell
            cell.name.stringValue = filesList[row].name
            if filesList[row].isFolder == true {
                cell.icon.image = NSImage(named: "NSFolder")
            } else {
                cell.icon.image = NSImage(named: "NSMultipleDocuments")
            }
            
            return cell
        } else {
            let cell = tableView.makeViewWithIdentifier("ServerItemModDateCell", owner: self) as! LFItemModDateItemCell
            cell.dateModified.stringValue = AppUtils.dateToStr(filesList[row].modifiedDate, withFormat: "EE, hh:mm a")
            return cell
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return filesList.count
    }

    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        return .Every
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if let droppedFileUrls = info.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? [String] {
            // FIXME: - filesList[row] can throw index out of range
            if filesList[row].isFolder == true {
                uploadFiles(atUrls: droppedFileUrls, toFolder: filesList[row].name, nil)
            } else {
                uploadFiles(atUrls: droppedFileUrls, toFolder: nil, nil)
            }
            return true
        }
        return false
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        return true
    }
    
    
    // MARK: - Selector methods
    
    func listServer(sender: AnyObject?) {
        print(__FUNCTION__)
        
        let board = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = board.instantiateControllerWithIdentifier("LFProgressWindowController")
        vc.showWindow(self)
        vc.makeMainWindow()
        
//        LFServerManager.uploadFile(1)
//        LFServerManager.uploadFile(2)
        
//        fetchDir((LFServerManager.activeServer?.destination)!, onComplete: nil)
//        currentPath = NSURL(string: (LFServerManager.activeServer?.destination)!)
    }
    
    // MARK: - Custom methods
    
    func fetchDir(path:String, onComplete: ((finish:Bool) -> Void)?) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            
            let resp = LFServerManager.ftpManager.contentsOfServer(LFServerManager.activeServer)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let data:[NSDictionary] = resp as? [NSDictionary] {
                    self.filesList.removeAll()
                    for i in data {
                        let fl = LFFile(name: i["kCFFTPResourceName"] as! String, modDate: i["kCFFTPResourceModDate"] as! NSDate, type: i["kCFFTPResourceType"] as! NSInteger)
                        self.filesList.append(fl)
                    }
                    self.filesListTableView.reloadData()
                    self.currentPath = NSURL(string: path)
                }
            })
        })
    }
    
    func uploadFiles(atUrls urls: [String], toFolder: String?, _: (() -> Void)?) {
        
        let fm = NSFileManager.defaultManager()
        for url in urls {
            if let attrs: NSDictionary = try? fm.attributesOfItemAtPath(url) {
                if attrs[NSFileType] as! String == NSFileTypeRegular {
                    // add file path to queue for uploading
                    filesQueue.enQueue(NSURL(string: url)!)
                }
            }
        }
        
        if !uploaderIsLooping {
            loopUploader()
        }
    }
    
    func loopUploader() {
        if (filesQueue.isEmpty()) {
            filenameProgress?.doubleValue = 0
            filenameLabel?.string = "Finished"
            uploaderIsLooping = false
            return
        }
        
        uploaderIsLooping = true
        
        let url:NSURL = filesQueue.deQueue()!
        
        filenameLabel?.string = url.lastPathComponent
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            let didUpload = LFServerManager.ftpManager.uploadFile(url, toServer: LFServerManager.activeServer)
            // TODO: if didUpload == false {// tell user }
            print("did upload file: \(didUpload)")
            
            // call completion block on complete
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loopUploader()
            })
        })
    }
    
    
    
    // MARK: - FTPManagerDelegate methods
    
    func ftpManagerUploadProgressDidChange(processInfo: [NSObject : AnyObject]!) {
        let progress = processInfo["progress"] as! Double
        filenameProgress?.doubleValue = progress * 100
    }
    
    func ftpManagerDownloadProgressDidChange(processInfo: [NSObject : AnyObject]!) {
        let progress = processInfo["progress"] as! Double
        filenameProgress?.doubleValue = progress * 100
    }
}

class LFFileNameItemCell: NSTableCellView {
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var name: NSTextField!
}

class LFItemModDateItemCell: NSTableCellView {
    @IBOutlet weak var dateModified: NSTextField!
}