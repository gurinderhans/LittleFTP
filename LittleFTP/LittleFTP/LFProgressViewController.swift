//
//  LFProgressViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/14/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

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
            cell.title.stringValue = "Uploading \(progressList[row]["file"] as! String)"
            cell.progressBar.doubleValue = progressList[row]["progress"] as! Double //0//Double(arc4random_uniform(90) + 30)
            
            let isUploadingThisFile = progressList[row]["uploading"] as! Bool
            if isUploadingThisFile == false {
                cell.progressText.stringValue = "Pending..."
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
                    for (i, filePath) in uploadFiles.enumerate() {
                        if let escapedStr = filePath.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
                            if let url = NSURL(string: escapedStr) {
                                progressList.append(["file": url.lastPathComponent!, "uploading": false, "progress": 0.0])
                                LFServerManager.uploadFile(url, cb: { info -> () in
                                    // FIXME: - here `i` is only updated once each file is uploaded making the upload manager seem like single threaded even thought it's not
                                    self.progressList[i]["progress"] = (info["progress"] as! Double) * 100
                                    self.progressList[i]["uploading"] = true
                                    self.progressListTableView.reloadData()
                                })
                            }
                        }
                    }
                    progressListTableView.reloadData()
            }
        }
    }
    
}

class LFProgressViewItem: NSTableCellView {
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var progressText: NSTextField!
}