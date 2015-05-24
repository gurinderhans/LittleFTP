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
    
    
	var mRemoteResources = [RemoteResource]()
	
    
    //
    // MARK: Outlets & Actions
    //
    
    
    @IBOutlet var fBrowserTableView:NSTableView?
    @IBOutlet var progress:NSProgressIndicator?
	@IBOutlet weak var progressPanel: NSView!
	@IBOutlet weak var progressPanel_fileNameLabel: NSTextField!
	@IBOutlet weak var progressPanelProgressBar: NSProgressIndicator!
    @IBOutlet weak var appWindow: NSWindow!
    
    
    
    //
    // MARK: App initialize methods
    //
    
    
    override init() {
        super.init()
		
        // initiate get files
		if ServerManager.activeServer.destination != nil { fetchDirContents("/") }
		
		// notification observer for adding overlay on browser table
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "overlayProgress:", name:"setOverlay", object: nil)

        // server change observer
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTable:", name:"serverChanged", object: nil)
		
		// listen for upload progress
		ServerManager.ftpManager.onProgress = {totalProgress, fileName in
			// TODO: get Action enum value from onProgress
			self.progressPanel_fileNameLabel.stringValue = fileName
			self.progressPanelProgressBar.doubleValue = totalProgress
		}
		
	}
	
    override func awakeFromNib() {
		
		fBrowserTableView?.target = self
        fBrowserTableView?.doubleAction = "fbBrowser_dblClick:"
        fBrowserTableView?.registerForDraggedTypes([kUTTypeFileURL])
		
        progress?.startAnimation(self)
		progressPanel.layer?.backgroundColor = NSColor.whiteColor().CGColor
		progressPanel.layer?.opacity = 0.95
    }
	
    
    
	//
	// MARK: Selector methods
    //
    
    
    func fbBrowser_dblClick(sender:AnyObject){
        let row = (fBrowserTableView?.clickedRow)!
        if row == -1 {return} // empty cell clicked
        
        let clickedResource = mRemoteResources[row]
        
        if clickedResource.resourceType! == 4 {
            self.progress?.hidden = false

			if (!ServerManager.isCreateDirsAndUploadFiles) { // dont allow switching dirs when there's an upload going on
				fetchDirContents(clickedResource.resourceName!)
			}
            
        } else {
            // TODO: download file
        }
    }
	
    
    // puts an overlay above the file browser
	func overlayProgress(sender:AnyObject) {
		ServerManager.isCreateDirsAndUploadFiles = sender.object as! Bool
		self.progressPanel.hidden = !(sender.object as! Bool)
		self.progressPanel_fileNameLabel.stringValue = "Loading..." // reset label
		self.progressPanelProgressBar.doubleValue = 0.0 // reset progress bar
		fBrowserTableView?.enabled = !ServerManager.isCreateDirsAndUploadFiles
	}
	
    // resets the file browser table
	func resetTable(sender:AnyObject) {
		self.progress?.hidden = false
		fetchDirContents("/")
	}
  
    
    
    //
    // MARK: NSTableViewDataSource methods
    //
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int { return mRemoteResources.count }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation operation: NSTableViewDropOperation) -> NSDragOperation { return NSDragOperation.Every }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation operation: NSTableViewDropOperation) -> Bool {
		
		var droppedURLs = (info.draggingPasteboard()
			.propertyListForType(NSFilenamesPboardType)! as! [String])
			.map { NSURL(string: $0) }

		var tmpConnectionObjs = [ConnectedPathModel]()
		
		let fm = NSFileManager.defaultManager()
		
		for i in 0...(droppedURLs.count-1) {
			let attribs: NSDictionary? = fm.attributesOfItemAtPath((droppedURLs[i]?.absoluteString)!, error: nil)
			
			if let fileattribs = attribs { // removing file name from path if it's a file
				if (fileattribs["NSFileType"] as! String) == "NSFileTypeRegular" {
					droppedURLs[i] = droppedURLs[i]?.URLByDeletingLastPathComponent
				}
			}
			
			var tmpConnectionObj:ConnectedPathModel = ConnectedPathModel (
				isEnabled: false,
				localPath: ((droppedURLs[i]?.URLByAppendingPathComponent(""))?.absoluteString)!, // by appending "" we add a / to the path
				remotePath: ""
			)
			
			if (operation.rawValue == 0 && mRemoteResources[row].resourceType == 4) { // if droppedOnTheCell
                // FIXME: remove the use of `parseServerURL`
				tmpConnectionObj.remotePath = AppUtils.parseServerURL(
					relativePath: ServerManager.activeServer.absolutePath,
					clickedItemPath: mRemoteResources[row].resourceName! )
			}
			else {
				tmpConnectionObj.remotePath = (ServerManager.activeServer.absolutePath == "") ? "/": ServerManager.activeServer.absolutePath
			}
	
			tmpConnectionObjs.append(tmpConnectionObj)
		}
		
		NSNotificationCenter.defaultCenter().postNotificationName("load", object: tmpConnectionObjs)
		
		return true
    }
    
    
    
    //
    // MARK: NSTableViewDelegate methods
    //
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let cellView: RemoteResourceCellView? = tableView.makeViewWithIdentifier("MainCell", owner: self)
			as? RemoteResourceCellView
		
		let remoteResource = mRemoteResources[row]
		
		cellView?.resourceTypeIcon.image = (remoteResource.resourceType == 4) ? NSImage(named: "folderIcon") : NSImage(named: "fileIcon")
		cellView?.resourceName.stringValue = remoteResource.resourceName!
		cellView?.resourceLastChanged.stringValue = AppUtils.dateToStr(remoteResource.resourceLastChanged!)
		
		return cellView
    }
	
    
    
    //
    // MARK: Custom methods
    //
    
    
	func fetchDirContents(path:String) {
        
        ServerManager.fetchDir(path, onFetched: { results -> Void in
            // hide progress
//            println("fetched")
            self.progress?.hidden = true
            // set window title to show current server directory that we are in
            println("sfsdfsdfsdf: [\(ServerManager.usingServer.serverAbsoluteURL)]")
//            self.appWindow.title = "\(ServerManager.usingServer.serverAbsoluteURL)"
            
            
            var remoteResources: [RemoteResource] = results as [RemoteResource]
            
            remoteResources.sort({$0.resourceType < $1.resourceType})
            
            self.mRemoteResources = remoteResources

            // insert only if server doesn't give us these
            // doing with a quick and dirty check
            if self.mRemoteResources.first?.resourceName != "." {
                self.mRemoteResources.insert(RemoteResource(resourceName: ".", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 0)
                self.mRemoteResources.insert(RemoteResource(resourceName: "..", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 1)

            }

            self.fBrowserTableView?.reloadData()
        })
    }
}



class RemoteResourceCellView: NSTableCellView {
    @IBOutlet var resourceTypeIcon:NSImageView!
    @IBOutlet var resourceName:NSTextField!
    @IBOutlet var resourceLastChanged:NSTextField!
}