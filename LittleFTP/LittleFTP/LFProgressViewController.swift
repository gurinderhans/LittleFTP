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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressListTableView.setDelegate(self)
        progressListTableView.setDataSource(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploadfiles:", name: "uploadfiles", object: nil)
    }
    
    // MARK: - NSTableViewDelegate & NSTabelViewDataSource methods
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeViewWithIdentifier("LFProgressViewItem", owner: self) as? LFProgressViewItem {
            cell.title.stringValue = "Uploading filename.zip to ftp.server.ca"
            cell.progressBar.doubleValue = Double(arc4random_uniform(90) + 30)
            return cell
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 55
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 5
    }
    
    // MARK: - Selector methods
    
    func uploadfiles(sender: AnyObject!) {
        print("upload files: \(sender.object)")
    }
    
}

class LFProgressViewItem: NSTableCellView {
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var progressText: NSTextField!
    
}