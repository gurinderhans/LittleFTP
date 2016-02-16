//
//  LFProgressViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/14/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa
import FTPManager

class LFProgressViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var progressListTableView: NSTableView!
    
    var progressList = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressListTableView.setDelegate(self)
        progressListTableView.setDataSource(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploadfiles:", name: "uploadfiles", object: nil)
    }
    
    // MARK: - NSTableViewDelegate & NSTableViewDataSource methods
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeViewWithIdentifier("LFProgressViewItem", owner: self) as? LFProgressViewItem {
            cell.title.stringValue = "Uploading \((progressList[row]["file"] as! NSURL).lastPathComponent!)"
            cell.progressBar.doubleValue = progressList[row]["percentprogress"] as! Double //0//Double(arc4random_uniform(90) + 30)
            
            let isUploadingThisFile = progressList[row]["uploading"] as! Bool
            if isUploadingThisFile == false {
                cell.progressText.stringValue = "Pending..."
            } else {
                cell.progressText.stringValue = "Uploading..."
            }
            
            return cell
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 55
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return progressList.count
    }
    
    // MARK: - Selector methods
    
    func uploadfiles(sender: AnyObject!) {
        if let data = sender.object as? [String: AnyObject] {
            if let uploadFiles = data["files"] as? [String],
                intoFolder = data["intofolder"] as? String {
                    
                    print(intoFolder) // to hide warning for now
                    
                    // TODO: - be careful since here the file name is escaped
                    for filePath in uploadFiles {
                        if let escapedStr = filePath.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
                            if let url = NSURL(string: escapedStr) {
                                progressList.append(["file": url, "uploading": false, "percentprogress": 0.0, "totalBytes": 0, "uploadedBytes": 0])
                            }
                        }
                    }
                    progressListTableView.reloadData()
            }
        }
        
        // upload files...
        //
    }
    
    func sendFile(url: NSURL, i: Int) {
        LFServerManager.uploadFile(url, finish: { success -> () in
            // remove file from list & reload table
        }) { progress -> () in
            // update progress for this file
        }
        
//            self.progressList[i]["progress"] = (info["progress"] as! Double) * 100
//            self.progressList[i]["uploading"] = true
//            self.progressListTableView.reloadData()
    }
    
}

class LFProgressViewItem: NSTableCellView {
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var progressText: NSTextField!
}