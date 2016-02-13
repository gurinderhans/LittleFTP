//
//  ConnectedPathsTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/31/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa
import SwiftFSWatcher

class ConnectedPathsTableViewController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	
    
    //
	// MARK: Singletons
    //
    
	let userDefaults = NSUserDefaults.standardUserDefaults()
    let mWatcher: SwiftFSWatcher = SwiftFSWatcher.createWatcher()
	
    
    //
	// MARK: Table data variables
    //
    
	var connectedPaths = [ConnectedPathModel]()
	var enabledConnections:[String] = []
	
    
    //
	// MARK: Outlets and Actions
    //
    
	@IBOutlet weak var connectedPathsTable: NSTableView!
    
	@IBAction func deleteConnectedPath(sender: AnyObject) {
        
        // get selected row and remove that row item
        if let selectedRow = connectedPathsTable?.rowForView(sender as! NSView) {
            connectedPaths.removeAtIndex(selectedRow)
        }

		// overwrite with new data
		userDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(connectedPaths),
			forKey: ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS)

        // reload table
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
//		mWatcher.onFileChange = {numEvents, changedPaths in
//            
//            // loop through both Sets and find the union
//            for i in self.connectedPaths {
//                for j in changedPaths {
//                    
//                    // to make sure this url is in the same format as our saved ones
//                    let changedPath = AppUtils.makeURL(j as! String, relativePath: "").absoluteString
//                    
//                    
//                    if self.isValidURL(i.localPath!, urlB: changedPath) == true {
//                        // upload the folder
//                        ServerManager.uploadData(localPath: i.localPath!, remotePath: i.remotePath!, onServer: ServerManager.activeServer)
//                        
////                        // let the user know we detected the change by posting a notification
////                        let notification = NSUserNotification()
////                        notification.title = "File Change"
////                        notification.informativeText = changedPath
////                        notification.soundName = NSUserNotificationDefaultSoundName
////                        
////                        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
//
//                    }
//                    
//                }
//            }
//		}
		
		// load saved ConnectedPaths
		if let data = userDefaults.objectForKey(ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS) as? NSData {
			connectedPaths = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ConnectedPathModel]
			
            // figure out enabled connections
			for i in connectedPaths {
				let connectionValue = (i.isEnabled == true) ? i.localPath! : ""
				enabledConnections.append(connectionValue)
			}
		}
		
		// load enabled watching paths and start watching on those
		let filteredConns = enabledConnections.filter { $0 != "" } // filter out empty strings, as these are disabled paths
		if filteredConns.count > 0 { // if we have enabled paths
//			mWatcher.paths =  NSMutableArray(array: filteredConns)
//			mWatcher.watch() // WATCH
		}
		
		// observe for the file drop data
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateConnectedPaths:", name:Observers.NEW_CONNECTION_PATH, object: nil)
		
		// server changed observer
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTable:", name:Observers.CURRENT_SERVER_CHANGED, object: nil)
	}
	
	override func awakeFromNib() {
        // add double click on table cell
		connectedPathsTable.target = self
		connectedPathsTable.doubleAction = "connectedPathsTblView_dblClick:"
	}
    
	
    
    //
	// MARK: Selector methods
    //
    
    
	func updateConnectedPaths(notification: NSNotification){
		// load data here
		for i in notification.object as! [ConnectedPathModel] {
			connectedPaths.append(i)
			enabledConnections.append("") // append empty because all connections by default are `OFF`
		}
		
		let data = NSKeyedArchiver.archivedDataWithRootObject(connectedPaths)
		userDefaults.setObject(data, forKey: ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS)
		connectedPathsTable?.reloadData()
		
	}
	
	func connectedPathsTblView_dblClick(sender:AnyObject){
		let row = (connectedPathsTable?.clickedRow)!
		if row == -1 { return }
		
		let clickedPath = connectedPaths[row]
		clickedPath.isEnabled = !clickedPath.isEnabled!
		
		if (enabledConnections.filter {$0 != ""}).count > 0 {
//			mWatcher.stop() // stop so we can change the paths
		}
		
		enabledConnections[row] = (clickedPath.isEnabled! == true) ? connectedPaths[row].localPath! : ""
		
		userDefaults.setObject( NSKeyedArchiver.archivedDataWithRootObject(connectedPaths),
			forKey: ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS)
		
		let watchPaths = enabledConnections.filter { $0 != "" }
		if watchPaths.count > 0 {
//			mWatcher.paths = NSMutableArray(array: watchPaths)
//			mWatcher.watch()
		}
		
		connectedPathsTable?.reloadData()
		
	}
	
	func reloadTable(sender:AnyObject) {
        
        // clear out data arrays
		enabledConnections.removeAll(keepCapacity: false)
		connectedPaths.removeAll(keepCapacity: false)
        
		// load new saved connected paths
		if let data = userDefaults.objectForKey(ServerManager.keyServerNameStringVal+Storage.CONNECTED_PATH_OBJS) as? NSData {

            // set connected paths
            connectedPaths = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ConnectedPathModel]
            
            // load enabled connections for the new server
			for i in connectedPaths {
				let connectionValue = (i.isEnabled == true) ? i.localPath! : ""
				enabledConnections.append(connectionValue)
			}
		}
        
        // filter connected array and start watching the enabled ones
		let filteredConns = enabledConnections.filter { $0 != "" }
		if filteredConns.count > 0 {
//			mWatcher.paths =  NSMutableArray(array: filteredConns)
//			mWatcher.watch()
		}
        
        // finally reload table
		connectedPathsTable.reloadData()
	}
	
    
    
    //
	// MARK: NSTableViewDataSource methods
    //
    
    
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return connectedPaths.count
	}
	
    
    //
	// MARK: NSTableViewDelegate methods
    //
    
    
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let cellView:ConnectedTableCellView = tableView.makeViewWithIdentifier("ConnectedFoldersCell", owner: self) as! ConnectedTableCellView
		let cPath = connectedPaths[row]
		
		cellView.localTitle.stringValue = cPath.localPath!
		cellView.remoteTitle.stringValue = cPath.remotePath!
		cellView.pathConnection.hidden = !cPath.isEnabled!
		cellView.pathRemoveButtonState.state = 1
		
		return cellView
	}
    
    
    //
    // MARK: Custom methods
    //
    
    func isValidURL(urlA: String, urlB: String) -> Bool {
        
        // get index to where we're going to stop
        let index = urlA.startIndex.advancedBy(urlA.characters.count)
        
        let a = urlA
        let b = urlB.substringToIndex(index)
        
        print("a:\(a), b:\(b), res:\(a == b)")
        
        // return wheteher the two strings are equal or not
        return a == b
    }
	
}

class ConnectedTableCellView:NSTableCellView {
	@IBOutlet var localTitle:NSTextField!
	@IBOutlet var remoteTitle:NSTextField!
	@IBOutlet var pathConnection:NSImageView!
	@IBOutlet var pathRemoveButtonState:NSButton!
}
