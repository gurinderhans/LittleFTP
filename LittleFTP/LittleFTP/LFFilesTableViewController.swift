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
    static let NAME_ID = "ServerFileNameCol"
    static let DATE_MOD_ID = "ServerFileModDateCol"
}

class LFFilesTableViewController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    override init() {
        super.init()
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == TableViewColIds.NAME_ID {
            return tableView.makeViewWithIdentifier("ServerFileNameCell", owner: self)
        } else {
            return tableView.makeViewWithIdentifier("ServerFileModDateCell", owner: self)
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 14
    }
}