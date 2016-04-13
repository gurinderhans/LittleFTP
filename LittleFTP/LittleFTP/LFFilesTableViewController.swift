//
//  LFFilesTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class LFFilesTableViewController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var filesListTableView: NSTableView!
    
    var filesList: [LFFile] = [LFFile]() {
        didSet {
            self.filesList.sortInPlace({ a, b -> Bool in
                return a.isFolder
            })
        }
    }
    
    var progressWindowController:LFProgressWindowController?
    
    override init() {
        super.init()
        
        /// register for Toolbar action button notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(openServer(_:)), name: UIActionNotificationObserverKeys.OPEN_SERVER, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(navigationChanged(_:)), name: UIActionNotificationObserverKeys.NAV_CHANGED, object: nil)
    }
    
    override func awakeFromNib() {
        filesListTableView.target = self
        filesListTableView.doubleAction = #selector(doubleClickRow(_:))
        filesListTableView.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    // MARK: - Selector methods
    
    func navigationChanged(sender: AnyObject!) {
        if let code = sender.object as? Int {
            if code == 0 { // BACK
                debugPrint("back")
                let newPath = LFServerManager.activeServer?.currentStandingUrl.URLByDeletingLastPathComponent
                LFServerManager.readPath(newPath!, files: { files in
                    if let files = files {
                        LFServerManager.activeServer?.currentStandingUrl = newPath
                        self.filesList = files
                        self.filesListTableView.reloadData()
                    }
                })
            } else if code == 1 {
                // FORWARD
                debugPrint("forward")
                if let currentComponents = LFServerManager.activeServer?.currentStandingUrl.pathComponents,
                    let forwardedComponents = LFServerManager.activeServer?.mostFowardedUrl.pathComponents {
                    if currentComponents.count < forwardedComponents.count {
                        var isNewUrl: Bool = false
                        for (idx, el) in currentComponents.enumerate() {
                            if el != forwardedComponents[idx] {
                                isNewUrl = true
                            }
                        }
                        if isNewUrl == false {
                            let newPath = LFServerManager.activeServer?.currentStandingUrl.URLByAppendingPathComponent(forwardedComponents[currentComponents.count], isDirectory: true).standardizedURL
                            LFServerManager.readPath(newPath!, files: { files in
                                if let files = files {
                                    LFServerManager.activeServer?.currentStandingUrl = newPath
                                    self.filesList = files
                                    self.filesListTableView.reloadData()
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func doubleClickRow(sender: AnyObject?) {
        print(#function)
        if filesListTableView.clickedRow > -1 {
            if filesList[filesListTableView.clickedRow].isFolder == true {
                openFolder(filesList[filesListTableView.clickedRow].name)
            } else {
                // download the file or something
            }
        }
    }
    
    // MARK: - NSTableViewDelegate & NSTableViewDataSource methods
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == TableViewColIds.NAME_ID {
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
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        return true
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if let droppedFileUrls = info.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? [String] {
            // TODO: check if dropped between rows or on a folder or outside table list
            uploadFiles(droppedFileUrls, intoFolder: ".")
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: - Selector methods
    
    func openServer(sender: AnyObject?) {
        debugPrint(#function)
        openFolder("/")
    }
    
    // MARK: - Custom methods
    
    func openFolder(folderName:String) {
         let newPath = LFServerManager.activeServer?.currentStandingUrl.URLByAppendingPathComponent(folderName, isDirectory: true).standardizedURL
        
        LFServerManager.readPath(newPath!) { files in
            if let files = files {
                LFServerManager.activeServer?.currentStandingUrl = newPath
                self.filesList = files
                self.filesListTableView.reloadData()
            }
        }
    }
    
    func uploadFiles(files: [String], intoFolder folder: String!) {
        print(#function)
//        if progressWindowController == nil {
//            progressWindowController = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("LFProgressWindowController") as? LFProgressWindowController
//        }
//        NSNotificationCenter.defaultCenter().postNotificationName("uploadfiles", object: ["files": files, "intofolder": folder])
//        progressWindowController?.showWindow(self)
    }
}

class LFFileNameItemCell: NSTableCellView {
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var name: NSTextField!
}

class LFItemModDateItemCell: NSTableCellView {
    @IBOutlet weak var dateModified: NSTextField!
}
