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
    @IBOutlet weak var uploadingFileName: NSTextField!
    @IBOutlet weak var uploadingFileProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var uploadingFileTextProgress: NSTextField!
    
    var progressList = [NSURL]()
    var filesSenderIsLooping: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressListTableView.setDelegate(self)
        progressListTableView.setDataSource(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LFProgressViewController.uploadfiles(_:)), name: "uploadfiles", object: nil)
    }
    
    // MARK: - NSTableViewDelegate & NSTableViewDataSource methods
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeViewWithIdentifier("LFProgressViewItem", owner: self) as? LFProgressViewItem {
            cell.title.stringValue = "Uploading \(progressList[row].lastPathComponent!)"
            
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
                                progressList.append(url)
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
    
    // MARK: - Custom methods
    
    func fileSendLooper() {
        
        if progressList.count == 0 {
            filesSenderIsLooping = false
            resetProgressView()
            NSNotificationCenter.defaultCenter().postNotificationName("closeWindow", object: nil)
            return
        }

        filesSenderIsLooping = true
        
        
        let url = progressList.first!

        resetProgressView()
        self.uploadingFileName.stringValue = url.lastPathComponent!

        self.progressList.removeFirst()
        self.progressListTableView.reloadData()
        
//        LFServerManager.uploadFile(url, finish: { success -> () in
//            self.fileSendLooper()
//        }, cb: { progress -> () in
//            self.uploadingFileProgressIndicator.doubleValue = (progress["progress"] as! Double) * 100
//            self.uploadingFileTextProgress.stringValue = "\(String(format: "%.01f", (progress["fileSizeProcessed"] as! Double) / 1000000)) MB of \(String(format: "%.01f", (progress["fileSize"] as! Double) / 1000000)) MB transferred"
//        })
    }
    
    func resetProgressView() {
        self.uploadingFileName.stringValue = "Loading..."
        self.uploadingFileProgressIndicator.doubleValue = 0
        self.uploadingFileTextProgress.stringValue = "Pending..."
    }
    
}

class LFProgressViewItem: NSTableCellView {
    @IBOutlet weak var title: NSTextField!
}