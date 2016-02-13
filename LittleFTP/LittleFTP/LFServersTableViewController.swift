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
    
    var serversList: [String] = ["hosting.ftp.domain", "domain.host", "ftp.server.com"]
    
    override init() {
        super.init()
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return tableView.makeViewWithIdentifier("DataCell", owner: self)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return serversList.count
    }
}