//
//  ServerBrowserTableViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/22/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa


class ServerBrowserTableViewController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    // FIXME: "unlockFocus called too many times. Called on <NSButton: 0x608000140630>"
	
	
    //
    // MARK: Table data variables
    //
    
    
	var remoteResources = [RemoteResource]()
	
    
    //
    // MARK: Outlets & Actions
    //
    
    
    // file browser table
    @IBOutlet var fileBrowserTblView:NSTableView?
    
    // panel overlays file browser table view to show file upload progress
    @IBOutlet weak var progressSpinner:NSProgressIndicator?
	@IBOutlet weak var progressPanel: NSView!
	@IBOutlet weak var progressPanel_fileNameLabel: NSTextField!
	@IBOutlet weak var progressPanelHorizontalProgress: NSProgressIndicator!
    
    // app window
    @IBOutlet weak var appWindow: NSWindow!
    
    
    
    //
    // MARK: App init
    //
    
    
    override init() {
        super.init()
		
		// when we start uploading files add a progress overlay
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "addProgressOverlay:", name: Observers.FILE_BROWSER_OVERLAY_PANEL, object: nil)

        // listen for server changes, and reset table when it does
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetFileBrowserTable:", name: Observers.CURRENT_SERVER_CHANGED, object: nil)

        // add file upload / download progress listener
        ServerManager.progressBlock = { type, progress, filename -> () in
            self.progressPanel_fileNameLabel.stringValue = filename
            self.progressPanelHorizontalProgress.doubleValue = progress
        }
        
        // initiate get files
        if ServerManager.activeServer.serverURL != nil { fetchDirContents("/") }
	}
	
    override func awakeFromNib() {
		
        // register tableview for drag/drop & for double click on each cell
		fileBrowserTblView?.target = self
        fileBrowserTblView?.doubleAction = "fileBrowserTblView_dblClick:"
        fileBrowserTblView?.registerForDraggedTypes([kUTTypeFileURL as String]) // for only files
		
        // start spinning the spinner
        progressSpinner?.startAnimation(self)
    }
	
    
    
	//
	// MARK: Selector methods
    //
    
    
    func fileBrowserTblView_dblClick(sender:AnyObject){
        
        if let row = fileBrowserTblView?.clickedRow {
            
            // we have clicked on a valid row
            if row != -1 {
                
                // get clicked item
                let clickedResource = remoteResources[row]
                
                // if we clicked on a folder, cd into it
                if clickedResource.resourceType == 4 {
                    
                    // show progress and fetch dir
                    self.progressSpinner?.hidden = false
                    
                    // prevent switching when FTP is working
                    if (!ServerManager.activeServer.isSpinning) {
                        fetchDirContents(clickedResource.resourceName)
                    }
                    
                } else {
                    // TODO: download file
                }
            }
        }
    }
	
    
    // puts an overlay above the file browser table view
	func addProgressOverlay(sender:AnyObject) {
        
        // set spinning to status of overlay display (true / false) & display / hide overlay
		ServerManager.activeServer.isSpinning = sender.object as! Bool
		self.progressPanel.hidden = !(sender.object as! Bool)
		self.progressPanel_fileNameLabel.stringValue = "Loading..." // reset label
		self.progressPanelHorizontalProgress.doubleValue = 0.0 // reset progress bar
		fileBrowserTblView?.enabled = !ServerManager.activeServer.isSpinning
        
	}
	
    
    // resets the file browser table by loading stuff from `/`
	func resetFileBrowserTable(sender:AnyObject) {
        
        // show the progress spinner
		self.progressSpinner?.hidden = false
        
        // fetch contents of new server
		fetchDirContents("/")
	}
  
    
    
    
    //
    // MARK: NSTableViewDelegate methods
    //
  
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // create cell view
        let cellView: RemoteResourceCellView? = tableView.makeViewWithIdentifier("MainCell", owner: self)
            as? RemoteResourceCellView
        
        // get remote resource to attach to cell
        let remoteResource = remoteResources[row]
        
        // fill up cell with the resource object
        cellView?.resourceTypeIcon.image = (remoteResource.resourceType == 4) ? NSImage(named: "folderIcon") : NSImage(named: "fileIcon")
        cellView?.resourceName.stringValue = remoteResource.resourceName!
        cellView?.resourceLastChanged.stringValue = AppUtils.dateToStr(remoteResource.resourceLastChanged!)
        
        // return.
        return cellView
    }
    
    
    
    
    //
    // MARK: NSTableViewDataSource methods
    //
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int { return remoteResources.count }
    
    // enable drop ops
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation operation: NSTableViewDropOperation) -> NSDragOperation { return NSDragOperation.Every }
    
    // on drop handle stuff
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation operation: NSTableViewDropOperation) -> Bool {
        
        // ref to file manager
        let fm = NSFileManager.defaultManager()
		
        // contains list of urls of file(s) / folder(s) that were dropped on the table
		let droppedURLs = (info.draggingPasteboard()
			.propertyListForType(NSFilenamesPboardType)! as! [String])
			.map { NSURL(string: $0) }

        // will hold our temp created connected paths
		var tmpConnectionObjs = [ConnectedPathModel]()
        
        for el in droppedURLs {
            if let urlAttrs: NSDictionary = try? fm.attributesOfItemAtPath((el?.absoluteString)!) {
                
                // now create a connection path
                let connection: ConnectedPathModel = ConnectedPathModel(isEnabled: false,
                    localPath: (el?.absoluteString)!,
                    remotePath: AppUtils.makeURL(ServerManager.activeServer.serverAbsoluteURL, relativePath: "").absoluteString)
                
                // removing file names from the local path
                if (urlAttrs["NSFileType"] as! String) == "NSFileTypeRegular" {
                    connection.localPath = (el?.URLByDeletingLastPathComponent?.absoluteString)!
                }
                
                // if the item is dropped on the cell and the cell is a folder, add that folder to path
                if operation.rawValue == 0 && remoteResources[row].resourceType == 4 {
                    connection.remotePath = AppUtils.makeURL(ServerManager.activeServer.serverAbsoluteURL,
                        relativePath: remoteResources[row].resourceName).absoluteString
                }
                
                tmpConnectionObjs.append(connection)
            }
        }

		NSNotificationCenter.defaultCenter().postNotificationName(Observers.NEW_CONNECTION_PATH, object: tmpConnectionObjs)
		
		return true
    }
	
    
    
    //
    // MARK: Custom methods
    //
    
    
	func fetchDirContents(path:String) {
        
        // set server to isSpinning
        ServerManager.activeServer.isSpinning = true
        
        // create goto path
        let gotoPath = AppUtils.makeURL(ServerManager.activeServer.serverAbsoluteURL, relativePath: path).absoluteString

        
        // then fetch dir
        ServerManager.list_directory(gotoPath, ofServer: ServerManager.activeServer) { contents -> Void in

            // hide progress
            self.progressSpinner?.hidden = true
            
            // set server to not spinning
            ServerManager.activeServer.isSpinning = false
            
            // update absolute path
            ServerManager.activeServer.serverAbsoluteURL = gotoPath
            
            // set window title
            /* _____ */
            
            // fill table data
            self.remoteResources = contents as [RemoteResource]
            
            // sort by type -> folders first, then files
            self.remoteResources.sortInPlace({$0.resourceType < $1.resourceType})
            
            // reload table
            self.fileBrowserTblView?.reloadData()
        }
    }
}



class RemoteResourceCellView: NSTableCellView {
    @IBOutlet var resourceTypeIcon:NSImageView!
    @IBOutlet var resourceName:NSTextField!
    @IBOutlet var resourceLastChanged:NSTextField!
}