//
//  UserTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/21/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class ServerUserTableViewController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	
	// MARK: Constants
	let userDefaults = NSUserDefaults.standardUserDefaults()
	let ACTION_CANCEL_TEXT = "Cancel"
	let ACTION_DELETE_TEXT = "Delete"
	let TITLE_EDIT_SERVER = "Edit Server"
	let TITLE_ADD_SERVER = "Add Server"
	
	// MARK: TableView data variables
	var allServers = [ServerModel]()
	var editingRow:Int = -1
	
	// MARK: Outlets & Actions
    @IBOutlet var serverTableView:NSTableView?
	@IBOutlet weak var mPopover: NSPopover!
	// popover text fields
	@IBOutlet weak var serverUrl: NSTextField!
	@IBOutlet weak var serverPort: NSTextField!
	@IBOutlet weak var serverUsername: NSTextField!
	@IBOutlet weak var serverPassword: NSSecureTextField!
	@IBOutlet weak var secondaryButton: NSButton!
	@IBOutlet weak var popoverTitle: NSTextField!
	
	// save server action
	@IBAction func saveServer(sender: AnyObject) {
		
		if serverUrl.stringValue != "" {
			let port = (serverPort.integerValue != 0) ? serverPort.integerValue : 21
			let uname = (serverUsername.stringValue != "") ? serverUsername.stringValue : "anonymous"
			let pass = (serverPassword.stringValue != "") ? serverPassword.stringValue : ""
			
			if popoverTitle.stringValue == TITLE_EDIT_SERVER {
				let editingServer = allServers[editingRow]
				editingServer.serverURL = serverUrl.stringValue
				editingServer.serverPort = port
				editingServer.userName = uname
				editingServer.userPass = pass
			} else {
				self.allServers.append( ServerModel(
					serverURL: serverUrl.stringValue,
					serverPort: port,
					userName: uname,
					userPass: pass,
					serverState: 0))
			}

			serverTableView?.reloadData()
			saveServers()
		}
		
		self.mPopover.close()

	}
    
    
	// add server action
	@IBAction func addServer(sender: AnyObject) {
		// show popover where the view is
        mPopover.showRelativeToRect(sender.bounds, ofView: sender as! NSView, preferredEdge: NSMaxXEdge)
		
        // set title's and stuff
        secondaryButton.title = ACTION_CANCEL_TEXT
		popoverTitle.stringValue = TITLE_ADD_SERVER
        
        // clear all fields and reset editing row
        serverUrl.stringValue = ""
        serverPort.intValue = 21
        serverUsername.stringValue = ""
        serverPassword.stringValue = ""
		editingRow = -1
	}
    
	// switch current server
	@IBAction func switchServer(sender: AnyObject) {
		let selectedRow = serverTableView?.rowForView(sender as! NSView)

		// change button states and stuff in the UI
		if allServers[selectedRow!].serverState! != 1 {
			let state = (self.allServers[selectedRow!].serverState == 0) ? 1:0
			for i in self.allServers { i.serverState = 0 }
			self.allServers[selectedRow!].serverState = state
			saveServers() // also save
			
			// update and tell table controllers
            ServerManager.usingServer = ServerManager.allServers()[selectedRow!]
//			ServerManager.activeServer = ServerManager.getAllServers()[selectedRow!]
			NSNotificationCenter.defaultCenter().postNotificationName("serverChanged", object: nil)
			
		} else {
			allServers[selectedRow!].serverState = 1
		}
		self.serverTableView?.reloadData()
	}
	
	
    
    //
	// MARK: App init methods
    //
    
    
    override init() {
        super.init()
		
		// load saved servers
		if let data = userDefaults.objectForKey(AppUtils.localStorageKeys.keyServerUsers.rawValue) as? NSData {
			allServers = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ServerModel]
		}
		
		// load active server
		var activeServer:ServerModel?
		for i in allServers {
			if i.serverState == 1 { activeServer = i }
		}
        
		if let server = activeServer {
            ServerManager.usingServer = server
            
//			ServerManager.activeServer = FMServer(
//				destination: server.serverURL!,
//				onPort: Int32(server.serverPort!),
//				username: server.userName!,
//				password: server.userPass!)
		}
		
		// notification observer for listening right clicks on switch Button
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchRightClick:", name:"switchRClick", object: nil)
		
    }
	
	override func awakeFromNib() {
		mPopover.behavior = NSPopoverBehavior.Transient
		secondaryButton.target = self
		secondaryButton.action = "manageSecondaryButton:"
	}
	
	// MARK: selector methods
	func manageSecondaryButton(sender: AnyObject) {
		if self.secondaryButton.title == ACTION_DELETE_TEXT {
			allServers.removeAtIndex(editingRow)
			saveServers()
			
			self.serverTableView?.reloadData()

		}
		self.mPopover.close()
	}
	
	func switchRightClick(notification: NSNotification) {
		secondaryButton.title = ACTION_DELETE_TEXT
		popoverTitle.stringValue = TITLE_EDIT_SERVER
		
		let view = notification.object as! NSView
		let selectedRow = serverTableView?.rowForView(view)
		editingRow = selectedRow!
		// load saved values in to their respective values
		let selectedServer = allServers[selectedRow!]
		serverUrl.stringValue = selectedServer.serverURL!
		serverPort.integerValue = selectedServer.serverPort!
		serverUsername.stringValue = selectedServer.userName!
		serverPassword.stringValue = selectedServer.userPass!
		
		mPopover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSMaxXEdge)
		
	}

	
	// MARK: NSTableViewDataSource methods
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return allServers.count
	}
	
	// MARK: NSTableView methods
    func tableViewSelectionDidChange(notification: NSNotification) {
        let selectedRow = (notification.object?.selectedRow)!
        if selectedRow == -1 { return }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {

		let cellView:ServerUserTableCellView? = tableView.makeViewWithIdentifier("ServerUserCell", owner: self) as? ServerUserTableCellView
        
        cellView?.serverUserImage?.image = NSImage(named: "server")
		cellView?.serverState.state = allServers[row].serverState!
		
        return cellView
    }
	
	// MARK: Custom methods
	func saveServers() {
		userDefaults.setObject( NSKeyedArchiver.archivedDataWithRootObject(allServers),
			forKey: AppUtils.localStorageKeys.keyServerUsers.rawValue)
	}
    

}

class ServerUserTableCellView:NSTableCellView {
    @IBOutlet var serverUserImage:NSImageView!
	@IBOutlet var serverState:NSButton!
}