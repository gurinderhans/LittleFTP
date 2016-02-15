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
    
    private var _filesList = [LFFile]()
    var filesList: [LFFile] {
        get { return _filesList }
        set(newArray) {
            _filesList = newArray.sort({ (a, b) -> Bool in
                return a.isFolder
            })
        }
    }
    
    var progressWindowController:LFProgressWindowController?
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "listServer:", name: "listServer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "navigationChanged:", name: "navigationChanged", object: nil)
    }
    
    override func awakeFromNib() {
        filesListTableView.target = self
        filesListTableView.doubleAction = "doubleClickRow:"
        filesListTableView.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    // MARK: - Selector methods
    
    func navigationChanged(sender: AnyObject!) {
//        if let code = sender.object as? Int {
//            if code == 0 {
//                // BACK
//                // TODO: nullity checks
//                let prevPath = currentPath.URLByDeletingLastPathComponent?.absoluteString
//                LFServerManager.activeServer?.destination = prevPath
//                fetchDir(prevPath!, onComplete: nil) // TOOD: onComplete set currentPath to new path
//            } else if code == 1 {
//                // FORWARD
//                print("forward")
//            }
//        }
    }
    
    func doubleClickRow(sender: AnyObject?) {
        print(__FUNCTION__)
        if filesListTableView.clickedRow > -1 {
            if filesList[filesListTableView.clickedRow].isFolder == true {
                fetchDir(filesList[filesListTableView.clickedRow].name)
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
    
    func listServer(sender: AnyObject?) {
        print(__FUNCTION__)
        fetchDir("/")
    }
    
    // MARK: - Custom methods
    
    func fetchDir(path:String) {
        LFServerManager.openFolder(withName: path) { files -> Void in
            if let files = files {
                self.filesList = files
                self.filesListTableView.reloadData()
            }
        }
    }
    
    func uploadFiles(files: [String], intoFolder folder: String!) {
        if progressWindowController == nil {
            progressWindowController = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("LFProgressWindowController") as? LFProgressWindowController
        }
        NSNotificationCenter.defaultCenter().postNotificationName("uploadfiles", object: ["files": files, "intofolder": folder])
        progressWindowController?.showWindow(self)
    }
}

class LFFileNameItemCell: NSTableCellView {
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var name: NSTextField!
}

class LFItemModDateItemCell: NSTableCellView {
    @IBOutlet weak var dateModified: NSTextField!
}
