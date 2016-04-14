//
//  LFProgressViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/14/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

typealias ProgressClosure = Int -> Void

class LFProgressViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var progressListTableView: NSTableView!
    
    var progressList = [ProgressPair]()
    var filesSenderIsLooping: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressListTableView.setDelegate(self)
        progressListTableView.setDataSource(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(uploadfiles(_:)), name: UIActionNotificationObserverKeys.UPLOAD_FILE, object: nil)
        
        NSTimer.scheduledTimerWithTimeInterval(0.11, target: self, selector: #selector(updateTable(_:)), userInfo: nil, repeats: true)
    }
    
    // MARK: - NSTableViewDelegate & NSTableViewDataSource methods
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeViewWithIdentifier("LFProgressViewItem", owner: self) as? LFProgressViewItem {
            cell.title.stringValue = "\(progressList[row].first)"
            cell.progressBar.doubleValue = Double(progressList[row].second) //progressList[row].second
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
        if let data = sender.object as? [String: AnyObject],
            let intoFolder = data["uploadPath"] as? NSURL ,
            let files = data["files"] as? [String] {
            
            for i in 0..<files.count {
                progressList.append(ProgressPair(files[i], 0))
                LFServerManager.uploadFiles(files.map { a -> LFFile in return LFFile(filePath: a) }, atPath: intoFolder, progressCb: { p in
                    self.progressList[i].second = p
                })
            }
        }
    }
    
    func updateTable(sender: AnyObject?) {
        debugPrint("update table")
        progressListTableView.reloadData()
    }

}

class LFProgressViewItem: NSTableCellView {
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
}


class ProgressPair {
    var first: String
    var second: Int
    init(_ a: String, _ b: Int) {
        self.first = a
        self.second = b
    }
}