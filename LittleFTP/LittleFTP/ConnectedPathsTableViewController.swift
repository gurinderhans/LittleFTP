//
//  ConnectedPathsTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/31/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class ConnectedPathsTableViewController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	
    
    //
	// MARK: Constants
    //
    
	let userDefaults = NSUserDefaults.standardUserDefaults()
	let mWatcher:MSwiftFileWatcher = MSwiftFileWatcher.createWatcher()
	
    
    //
	// MARK: Table data variables
    //
    
	var allConnectedPaths = [ConnectedPathModel]()
	var enabledConnections:[String] = []
	
    
    //
	// MARK: Outlets and Actions
    //
    
	@IBOutlet weak var connectedPathsTable: NSTableView!
	@IBAction func deleteConnectedPath(sender: AnyObject) {
		let selectedRow = connectedPathsTable?.rowForView(sender as! NSView)
		allConnectedPaths.removeAtIndex(selectedRow!)

		// overwrite with new data
		userDefaults.setObject( NSKeyedArchiver.archivedDataWithRootObject(allConnectedPaths),
			forKey: ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS)

		connectedPathsTable?.reloadData()
	}
	
    
    //
	// MARK: init
    //
    
	override init() {
		/** Init:
		* 1. start listening for file changes
		* 2. load connectedPaths into table
		* 3. start watching on enabled connections
		*/
		super.init()
		// listen for file system changes
		mWatcher.onFileChange = {numEvents, changedPaths in
			for i in changedPaths {
				for j in self.allConnectedPaths {
					if j.localPath! == i as! String {
						// upload contents from j.localpath to j.remotePath
						 ServerManager.uploadData(localPath: j.localPath!, remotePath: j.remotePath!)
						let notification = NSUserNotification()
						notification.title = "File Change"
						notification.informativeText = j.localPath!
						notification.soundName = NSUserNotificationDefaultSoundName
						
						NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
					}
				}
			}
		}
		
		// load saved ConnectedPaths
		if let data = userDefaults.objectForKey(ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS) as? NSData {
			allConnectedPaths = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ConnectedPathModel]
			
			for i in allConnectedPaths {
				let connectionValue = (i.isEnabled == true) ? i.localPath! : ""
				enabledConnections.append(connectionValue)
			}
		}
		
		// load enabled watching paths and start watching on those
		let filteredConns = enabledConnections.filter { $0 != "" }
		if filteredConns.count > 0 {
			mWatcher.paths =  NSMutableArray(array: filteredConns)
			mWatcher.watch()
		}
		
		// observe for the file drop data
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateConnectedPaths:", name:"load", object: nil)
		
		// server changed observer
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTable:", name:"serverChanged", object: nil)
	}
	
	override func awakeFromNib() {
		connectedPathsTable.target = self
		connectedPathsTable.doubleAction = "cPaths_dblClick:"
	}
	
	// MARK: Selector methods
	func updateConnectedPaths(notification: NSNotification){
		//load data here
		for i in notification.object as! [ConnectedPathModel] {
			allConnectedPaths.append(i)
			enabledConnections.append("") // append empty because all connections by default are `OFF`
		}
		
		let data = NSKeyedArchiver.archivedDataWithRootObject(allConnectedPaths)
		userDefaults.setObject(data, forKey: ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS)
		connectedPathsTable?.reloadData()
		
	}
	
	func cPaths_dblClick(sender:AnyObject){
		let row = (connectedPathsTable?.clickedRow)!
		if row == -1 { return }
		
		let clickedPath = allConnectedPaths[row]
		clickedPath.isEnabled = !clickedPath.isEnabled!
		
		if (enabledConnections.filter {$0 != ""}).count > 0 {
			mWatcher.stop() // stop so we can change the paths
		}
		
		enabledConnections[row] = (clickedPath.isEnabled! == true) ? allConnectedPaths[row].localPath! : ""
		
		userDefaults.setObject( NSKeyedArchiver.archivedDataWithRootObject(allConnectedPaths),
			forKey: ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS)
		
		let watchPaths = enabledConnections.filter { $0 != "" }
		if watchPaths.count > 0 {
			mWatcher.paths = NSMutableArray(array: watchPaths)
			mWatcher.watch()
		}
		
		connectedPathsTable?.reloadData()
		
	}
	
	func reloadTable(sender:AnyObject) {
		enabledConnections = []
		allConnectedPaths = []
		// load saved ConnectedPaths
		if let data = userDefaults.objectForKey(ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS) as? NSData {
			allConnectedPaths = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ConnectedPathModel]
			for i in allConnectedPaths {
				let connectionValue = (i.isEnabled == true) ? i.localPath! : ""
				enabledConnections.append(connectionValue)
			}
		}
		let filteredConns = enabledConnections.filter { $0 != "" }
		if filteredConns.count > 0 {
			mWatcher.paths =  NSMutableArray(array: filteredConns)
			mWatcher.watch()
		}
		connectedPathsTable.reloadData()
	}
	
	// MARK: NSTableViewDataSource methods
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return allConnectedPaths.count
	}
	
	// MARK: NSTableViewDelegate methods
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let cellView:ConnectedTableCellView = tableView.makeViewWithIdentifier("ConnectedFoldersCell", owner: self) as! ConnectedTableCellView
		let cPath = allConnectedPaths[row]
		
		cellView.localTitle.stringValue = cPath.localPath!
		cellView.remoteTitle.stringValue = cPath.remotePath!
		cellView.pathConnection.hidden = !cPath.isEnabled!
		cellView.pathRemoveButtonState.state = 1
		
		return cellView
	}
	
}

class ConnectedTableCellView:NSTableCellView {
	@IBOutlet var localTitle:NSTextField!
	@IBOutlet var remoteTitle:NSTextField!
	@IBOutlet var pathConnection:NSImageView!
	@IBOutlet var pathRemoveButtonState:NSButton!
}
