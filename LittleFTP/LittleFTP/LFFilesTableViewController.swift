//
//  LFFilesTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

struct TableViewColIds {
    static let NAME_ID = "NameCol"
    static let DATE_MOD_ID = "ModDateCol"
}

class LFFilesTableViewController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
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
    
    var currentPath: NSURL!
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "listServer:", name: "listServer", object: nil)
    }
    
    override func awakeFromNib() {
        filesListTableView.target = self
        filesListTableView.doubleAction = "doubleClickRow:"
    }
    
    // MARK: - Selector methods
    
    func doubleClickRow(sender: AnyObject?) {
        print("dbl clicked row")
        if filesList[filesListTableView.clickedRow].isFolder == true {
            let path = currentPath.URLByAppendingPathComponent(filesList[filesListTableView.clickedRow].name, isDirectory: filesList[filesListTableView.clickedRow].isFolder).absoluteString
            LFServerManager.activeServer?.destination = path
            fetchDir(path) { (finish) -> Void in
                //
            }
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
            cell.dateModified.stringValue = AppUtils.dateToStr(filesList[row].modifiedDate, withFormat: "EE hh:mm a dd/yy")
            return cell
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return filesList.count
    }
    
    // MARK: - Selector methods
    
    func listServer(sender: AnyObject?) {
        print(__FUNCTION__)
        fetchDir((LFServerManager.activeServer?.destination)!, onComplete: nil)
        currentPath = NSURL(string: (LFServerManager.activeServer?.destination)!)
    }
    
    // MARK: - Custom methods
    
    func fetchDir(path:String, onComplete: ((finish:Bool) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            
            print("fetch: \(path)")
//            print("fetch: \(self.currentPath.ab)")
            
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
}

class LFFileNameItemCell: NSTableCellView {
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var name: NSTextField!
}

class LFItemModDateItemCell: NSTableCellView {
    @IBOutlet weak var dateModified: NSTextField!
}