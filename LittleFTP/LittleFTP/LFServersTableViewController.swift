//
//  LFServersTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class LFServersTableViewController: NSObject, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var serversListTableView: NSTableView!
    
    override init() {
        super.init()
    }
    
    override func awakeFromNib() {
        serversListTableView.target = self
        serversListTableView.doubleAction = #selector(doubleClickRow(_:))
    }
    
    // MARK: - Selector methods
    
    func doubleClickRow(sender: NSTableView!) {
        if sender.clickedRow > 0 {
            openServer(LFServerManager.savedServers[sender.clickedRow - 1])
        }
    }
    
    // MARK: - NSTableViewDelegate & NSTableViewDataSource methods
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row == 0 {
            return tableView.makeViewWithIdentifier("HeaderCell", owner: self)
        } else {
            let cell = tableView.makeViewWithIdentifier("DataCell", owner: self) as! LFServerItemCell
            cell.hostname.stringValue = LFServerManager.savedServers[row - 1].hostname
            return cell
        }
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 {
            return 25.0
        } else {
            return 30.0
        }
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return row != 0
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return LFServerManager.savedServers.count + 1
    }
    
    
    // MARK: - Custom methods
    
    func openServer(server: LFServer) {
        debugPrint(#function)
        if let _ = LFServerManager.activeServer {
            debugPrint("closing an already opened instance of another server")
            // TODO: - support multi server ops and switching servers
            // new window for each different server
        } else {
            LFServerManager.activeServer = server
            NSNotificationCenter.defaultCenter().postNotificationName(UIActionNotificationObserverKeys.OPEN_SERVER, object: nil)
        }
    }
}

class LFServerItemCell: NSTableCellView {
    @IBOutlet weak var hostname: NSTextField!
}