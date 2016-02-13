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
    
    @IBOutlet var serverTableView:NSTableView?
    @IBOutlet weak var popoverForm: NSPopover!
    
    // popover text fields
    @IBOutlet weak var serverUrl: NSTextField!
    @IBOutlet weak var serverPort: NSTextField!
    @IBOutlet weak var serverUsername: NSTextField!
    @IBOutlet weak var serverPassword: NSSecureTextField!
    @IBOutlet weak var popoverTitle: NSTextField!
    @IBOutlet weak var secondaryButton: NSButton!
	
	let ACTION_CANCEL_TEXT = "Cancel",
        ACTION_DELETE_TEXT = "Delete";
    
	let TITLE_EDIT_SERVER = "Edit Server",
        TITLE_ADD_SERVER = "Add Server";
    
    let APP_DATA = NSUserDefaults.standardUserDefaults()
	
	var savedServers = [ServerModel]()
	
	// save server action
	@IBAction func saveServer(sender: AnyObject) {
        
        print("saving server...")
        
        // Input sanitization and checks
        let host = serverUrl.stringValue
        let port = serverPort.stringValue
        let uname = serverUsername.stringValue
        let pass = serverPassword.stringValue
        if !host.isEmpty && !port.isEmpty && !uname.isEmpty && !pass.isEmpty {
            print("passed input checks")
            
            let newServer = ServerModel(host: host, port: port, uname: uname, pass: pass)
            savedServers.append(newServer)
            serverTableView?.reloadData()
            popoverForm.close()
        }
	}
    
	@IBAction func addServer(sender: AnyObject) {
        popoverTitle.stringValue = TITLE_ADD_SERVER
        secondaryButton.title = ACTION_CANCEL_TEXT
        fillForm(withServer: nil)
        popoverForm.showRelativeToRect(sender.bounds, ofView: sender as! NSView, preferredEdge: NSRectEdge.MaxX)
	}
    
    
	// switch from this server to another
	@IBAction func switchServer(sender: AnyObject) {
//        if let selectedRow = serverTableView?.rowForView(sender as! NSView) {
//            
//            //
//            // change button states and stuff in the UI
//            //
//            
//            
//            // reset all to 0
//            for i in self.savedServers { i.serverState = 0 }
//            
//            // set this to 1 and save changes
//            self.savedServers[selectedRow].serverState = 1
//            saveServers()
//            
//            // update and tell table controllers
////            ServerManager.activeServer = createdServers[selectedRow]
//            NSNotificationCenter.defaultCenter().postNotificationName("serverChanged", object: nil)
//
//        }
//        
//		self.serverTableView?.reloadData()
	}
    
	
    
	// MARK: - App init methods
    
    override init() {
        super.init()
		
//		// load saved servers
//		savedServers = ServerManager.allServers()
//		
//		// load active server
//		var activeServer:ServerModel?
//		for i in savedServers {
//			if i.serverState == 1 { activeServer = i }
//		}
//        if let _ = activeServer{}
//        
//        ServerManager.activeServer = activeServer!
		
		// notification observer for listening right clicks on switch button notification gets sent from the button view
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchRightClick:", name:"switchRightClick", object: nil)
    }
	
	override func awakeFromNib() {
		popoverForm.behavior = NSPopoverBehavior.Transient
		secondaryButton.target = self
		secondaryButton.action = "manageSecondaryButton:"
	}
	
	
    // MARK: - Selector methods
    
    func manageSecondaryButton(sender: AnyObject) {
		if self.secondaryButton.title == ACTION_DELETE_TEXT {
//			savedServers.removeAtIndex(editingRow)
			saveServers()
			
			self.serverTableView?.reloadData()

		}
		self.popoverForm.close()
	}
	
	func switchRightClick(notification: NSNotification) {
		secondaryButton.title = ACTION_DELETE_TEXT
		popoverTitle.stringValue = TITLE_EDIT_SERVER

        let view = notification.object as! NSView
        if let selectedRow = serverTableView?.rowForView(view) {
            fillForm(withServer: savedServers[selectedRow])
            popoverForm.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSRectEdge.MaxX)
        } else {
            // TODO: display an error occured trying to edit server
        }
	}
    
	
    
    // MARK: - NSTableViewDataSource methods
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return savedServers.count
    }
	

    // MARK: - NSTableView methods
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if let selectedRow = notification.object?.selectedRow {
            if selectedRow == -1 { return }
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cellView:ServerUserTableCellView? = tableView.makeViewWithIdentifier("ServerUserCell", owner: self) as? ServerUserTableCellView
        cellView?.serverUserImage?.image = NSImage(named: "server")
		cellView?.serverState.state = 1
        return cellView
    }
	
    
	// MARK: - Custom methods
    
    
    func fillForm(withServer server: ServerModel?) {
        if let s = server { // fill with this server info
            serverUrl.stringValue = s.serverURL
            serverPort.stringValue = s.serverPort
            serverUsername.stringValue = s.userName
            serverPassword.stringValue = s.userPass
        } else { // clear all fields
            serverUrl.stringValue = ""
            serverPort.stringValue = "21"
            serverUsername.stringValue = ""
            serverPassword.stringValue = ""
        }
    }
    
    
	func saveServers() {
//		APP_DATA.setObject( NSKeyedArchiver.archivedDataWithRootObject(savedServers),
//			forKey: Storage.SERVERS)
	}
    
}

class ServerUserTableCellView:NSTableCellView {
    @IBOutlet var serverUserImage:NSImageView!
	@IBOutlet var serverState:NSButton!
}