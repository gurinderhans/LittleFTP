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
    var filesSenderIsLooping: Bool = false
    
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
                cell.progressText.stringValue = "\((progressList[row]["uploadedBytes"] as! Int) / 1000000) MB of \((progressList[row]["totalBytes"] as! Int) / 1000000) MB transferred"
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
        if !filesSenderIsLooping {
            fileSendLooper()
        }
    }
    
    func fileSendLooper() {
        
        if progressList.count == 0 {
            filesSenderIsLooping = false
            return
        }

        filesSenderIsLooping = true
        let url = progressList[0]["file"] as! NSURL
        LFServerManager.uploadFile(url, finish: { success -> () in
            self.progressList.removeFirst()
            self.progressListTableView.reloadData()
            self.fileSendLooper()
        }, cb: { progress -> () in
            print(progress)
            self.progressList[0]["uploading"] = true
            self.progressList[0]["percentprogress"] = (progress["progress"] as! Double) * 100
            self.progressList[0]["totalBytes"] = progress["fileSize"] as! Int
            self.progressList[0]["uploadedBytes"] = progress["fileSizeProcessed"] as! Int
            self.progressListTableView.
            self.progressListTableView.reloadData()
        })
    }
    
}

class LFProgressViewItem: NSTableCellView {
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var progressText: NSTextField!
}