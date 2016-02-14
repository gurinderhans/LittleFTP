//
//  LFServersTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa
import FTPManager

class LFServersTableViewController: NSObject, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var serversListTableView: NSTableView!
    
    var serversList = [LFServer]()
    
    let APPDATA = NSUserDefaults.standardUserDefaults()
    
    override init() {
        super.init()
        
        if let data = APPDATA.objectForKey("allservers") as? NSData {
            serversList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [LFServer]
        }
    }
    
    override func awakeFromNib() {
        serversListTableView.target = self
        serversListTableView.doubleAction = "doubleClickRow:"
    }
    
    // MARK: - Selector methods
    
    func doubleClickRow(sender: NSTableView!) {
        openServer(serversList[sender.clickedRow-1])
    }
    
    // MARK: - NSTableViewDelegate & NSTableViewDataSource methods
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row == 0 {
            return tableView.makeViewWithIdentifier("HeaderCell", owner: self)
        } else {
            let cell = tableView.makeViewWithIdentifier("DataCell", owner: self) as! LFServerItemCell
            cell.hostname.stringValue = serversList[row-1].hostname
            return cell
        }
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 {
            return 25.0
        }
        return 30.0
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return row != 0
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return serversList.count + 1
    }
    
    
    // MARK: - Custom methods
    
    func openServer(server: LFServer) {
        print(__FUNCTION__)
        if let _ = LFServerManager.activeServer {
            print("closing an already opened instance of another server")
            // TODO: close the server or not
            LFServerManager.activeServer = nil
        }
        
        print("now opening server")
        LFServerManager.activeServer = FMServer(destination: server.hostname, username: server.userName, password: server.password)
        LFServerManager.activeServer?.port = Int32(server.port)!
        listServer()
    }
    
    func listServer() {
        NSNotificationCenter.defaultCenter().postNotificationName("listServer", object: nil)
    }
    
    
}

class LFServerItemCell: NSTableCellView {
    @IBOutlet weak var hostname: NSTextField!
}