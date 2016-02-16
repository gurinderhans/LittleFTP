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
            cell.progressBar.doubleValue = 0//Double(arc4random_uniform(90) + 30)
            
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
                    print(intoFolder)
                    // TODO: - be careful since here the file name is excaped
                    progressList.appendContentsOf(uploadFiles.map({ (a) -> [String: AnyObject] in
                        return ["file": (NSURL(string: a.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)?.lastPathComponent)!, "uploading": false]
                    }))
                    progressListTableView.reloadData()
            }
        }
        
//        let fm = LFFtpManager()
//        fm.uploadFile(NSURL(string: "filepath/name.ext")!, withServer: FMServer(destination: "hostname", username: "username", password: "password")) { (info) -> () in
//            print(info)
    }
    
}

class LFProgressViewItem: NSTableCellView {
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var progressText: NSTextField!
}