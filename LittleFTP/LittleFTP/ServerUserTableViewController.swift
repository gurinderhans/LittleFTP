//
//  ServerUserTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/21/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class ServerUserTableViewController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	
	// MARK: Constants
	let ACTION_CANCEL_TEXT = "Cancel"
	let ACTION_DELETE_TEXT = "Delete"
	let TITLE_EDIT_SERVER = "Edit Server"
	let TITLE_ADD_SERVER = "Add Server"
    let userDefaults = NSUserDefaults.standardUserDefaults()
	
    
    //
	// MARK: TableView data variables
    //
    
	var createdServers = [ServerModel]()
	var editingRow:Int = -1
	
    
    //
	// MARK: Outlets & Actions
    //
    
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
				let editingServer = createdServers[editingRow]
				editingServer.serverURL = serverUrl.stringValue
				editingServer.serverPort = port
				editingServer.userName = uname
				editingServer.userPass = pass
			} else {
				self.createdServers.append( ServerModel(
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
    
    
	// add new server button action
	@IBAction func addServer(sender: AnyObject) {

        // set title's and stuff
        popoverTitle.stringValue = TITLE_ADD_SERVER
        secondaryButton.title = ACTION_CANCEL_TEXT
        
        // clear all fields and reset editing row
        serverUrl.stringValue = ""
        serverPort.intValue = 21
        serverUsername.stringValue = ""
        serverPassword.stringValue = ""
        
        // we aren't editing any server right now
		editingRow = -1
        
        // show popover where the view is, where we clicked
        mPopover.showRelativeToRect(sender.bounds, ofView: sender as! NSView, preferredEdge: NSMaxXEdge)
	}
    
    
	// switch from this server to another
	@IBAction func switchServer(sender: AnyObject) {
		
        if let selectedRow = serverTableView?.rowForView(sender as! NSView) {
            
            //
            // change button states and stuff in the UI
            //
            
            
            // reset all to 0
            for i in self.createdServers { i.serverState = 0 }
            
            // set this to 1 and save changes
            self.createdServers[selectedRow].serverState = 1
            saveServers()
            
            // update and tell table controllers
            ServerManager.activeServer = createdServers[selectedRow]
            NSNotificationCenter.defaultCenter().postNotificationName("serverChanged", object: nil)

        }
        
		self.serverTableView?.reloadData()
	}
    
	
    
    //
	// MARK: App init methods
    //
    
    override init() {
        super.init()
		
		// load saved servers
		createdServers = ServerManager.allServers()
		
		// load active server
		var activeServer:ServerModel?
		for i in createdServers {
			if i.serverState == 1 { activeServer = i }
		}
        ServerManager.activeServer = activeServer!
		
		// notification observer for listening right clicks on switch Button
        // notification gets sent from the button view
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchRightClick:", name:"switchRClick", object: nil)
		
    }
	
	override func awakeFromNib() {
		mPopover.behavior = NSPopoverBehavior.Transient
		secondaryButton.target = self
		secondaryButton.action = "manageSecondaryButton:"
	}
	
    
    
    //
	// MARK: selector methods
	//
    
    
    func manageSecondaryButton(sender: AnyObject) {
		if self.secondaryButton.title == ACTION_DELETE_TEXT {
			createdServers.removeAtIndex(editingRow)
			saveServers()
			
			self.serverTableView?.reloadData()

		}
		self.mPopover.close()
	}
	
	func switchRightClick(notification: NSNotification) {
        
        // set title and secondary button action value
		secondaryButton.title = ACTION_DELETE_TEXT
		popoverTitle.stringValue = TITLE_EDIT_SERVER
		
        // get selected row index
		let view = notification.object as! NSView
		let selectedRow = serverTableView?.rowForView(view)
        
        // we are editing this row
		editingRow = selectedRow!
        
		// load saved values in to their respective values
		let selectedServer = createdServers[selectedRow!]
		serverUrl.stringValue = selectedServer.serverURL!
		serverPort.integerValue = selectedServer.serverPort!
		serverUsername.stringValue = selectedServer.userName!
		serverPassword.stringValue = selectedServer.userPass!
		
        // show popover where the view is, where we clicked
		mPopover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSMaxXEdge)
		
	}
    
	
    
    //
    // MARK: NSTableViewDataSource methods
	//
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int { return createdServers.count }
	
	
    
    //
    // MARK: NSTableView methods
    //
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if let selectedRow = notification.object?.selectedRow {
            if selectedRow == -1 { return }
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cellView:ServerUserTableCellView? = tableView.makeViewWithIdentifier("ServerUserCell", owner: self) as? ServerUserTableCellView
        cellView?.serverUserImage?.image = NSImage(named: "server")
		cellView?.serverState.state = createdServers[row].serverState!
        return cellView
    }
	
    
    //
	// MARK: Custom methods
    //
    
    
	func saveServers() {
		userDefaults.setObject( NSKeyedArchiver.archivedDataWithRootObject(createdServers),
			forKey: Storage.SERVERS)
	}
    

}

class ServerUserTableCellView:NSTableCellView {
    @IBOutlet var serverUserImage:NSImageView!
	@IBOutlet var serverState:NSButton!
}