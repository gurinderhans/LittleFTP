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
	
	// MARK: Table data variables
	var mRemoteResources = [RemoteResource]()
	
    // MARK: Outlets & Actions
    @IBOutlet var fBrowserTableView:NSTableView?
    @IBOutlet var progress:NSProgressIndicator?
	@IBOutlet weak var progressPanel: NSView!
	@IBOutlet weak var progressPanel_fileNameLabel: NSTextField!
	@IBOutlet weak var progressPanelProgressBar: NSProgressIndicator!
    
    
    // MARK: App initialize methods
    override init() {
        super.init()
		
        // initiate get files
		if ServerManager.activeServer.destination != nil { fetchDirContents(path: "/") }
		
		// notification observer for adding overlay on browser table
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "overlayProgress:", name:"setOverlay", object: nil)
		// server change observer
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTable:", name:"serverChanged", object: nil)
		
		// listen for upload progress
		ServerManager.ftpManager.onProgress = {totalProgress, fileName in
			// get Action enum value from onProgress
			self.progressPanel_fileNameLabel.stringValue = fileName // not feeling so good about this line
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
	
	
	// MARK: Selector methods
    func fbBrowser_dblClick(sender:AnyObject){
        let row = (fBrowserTableView?.clickedRow)!
        if row == -1 {return} // empty cell clicked
        self.progress?.hidden = false
        
        let clickedResource = mRemoteResources[row]
        
        if clickedResource.resourceType! == 4 {
            let subPath = clickedResource.resourceName!+"/"
			if (!ServerManager.isCreateDirsAndUploadFiles) { // dont allow switching dirs when there's an upload going on
				fetchDirContents(path: subPath)
			}
        }
    }
	
	func overlayProgress(sender:AnyObject) {
		ServerManager.isCreateDirsAndUploadFiles = sender.object as Bool
		self.progressPanel.hidden = !(sender.object as Bool)
		self.progressPanel_fileNameLabel.stringValue = "Loading..." // reset label
		self.progressPanelProgressBar.doubleValue = 0.0 // reset progress bar
		fBrowserTableView?.enabled = !ServerManager.isCreateDirsAndUploadFiles
	}
	
	func reloadTable(sender:AnyObject) {
		self.progress?.hidden = false
		fetchDirContents(path: "/")
	}
    
    
    
    // MARK: NSTableViewDataSource methods
    func numberOfRowsInTableView(tableView: NSTableView) -> Int { return mRemoteResources.count }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation operation: NSTableViewDropOperation) -> NSDragOperation { return NSDragOperation.All }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation operation: NSTableViewDropOperation) -> Bool {
		
		var droppedURLs = (info.draggingPasteboard()
			.propertyListForType(NSFilenamesPboardType)! as [String])
			.map { NSURL(string: $0) }

		var tmpConnectionObjs = [ConnectedPathModel]()
		
		let fm = NSFileManager.defaultManager()
		
		for i in 0...(droppedURLs.count-1) {
			let attribs: NSDictionary? = fm.attributesOfItemAtPath((droppedURLs[i]?.absoluteString)!, error: nil)
			
			if let fileattribs = attribs { // removing file name from path if it's a file
				if (fileattribs["NSFileType"] as String) == "NSFileTypeRegular" {
					droppedURLs[i] = droppedURLs[i]?.URLByDeletingLastPathComponent
				}
			}
			
			var tmpConnectionObj:ConnectedPathModel = ConnectedPathModel (
				isEnabled: false,
				localPath: ((droppedURLs[i]?.URLByAppendingPathComponent(""))?.absoluteString)!, // by appending "" we add a / to the path
				remotePath: ""
			)
			
			if (operation.rawValue == 0 && mRemoteResources[row].resourceType == 4) { // if droppedOnTheCell
				tmpConnectionObj.remotePath = AppUtils.parseServerURL(
					relativePath: ServerManager.activeServer.relativePath,
					clickedItemPath: mRemoteResources[row].resourceName! )
			}
			else {
				tmpConnectionObj.remotePath = (ServerManager.activeServer.relativePath == "") ? "/": ServerManager.activeServer.relativePath
			}
	
			tmpConnectionObjs.append(tmpConnectionObj)
		}
		
		NSNotificationCenter.defaultCenter().postNotificationName("load", object: tmpConnectionObjs)
		
		return true
    }
    
    // MARK: NSTableViewDelegate methods
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let cellView: RemoteResourceCellView? = tableView.makeViewWithIdentifier("MainCell", owner: self)
			as? RemoteResourceCellView
		
		let remoteResource = mRemoteResources[row]
		
		cellView?.resourceTypeIcon.image = (remoteResource.resourceType == 4) ? NSImage(named: "folderIcon") : NSImage(named: "fileIcon")
		cellView?.resourceName.stringValue = remoteResource.resourceName!
		cellView?.resourceLastChanged.stringValue = AppUtils.dateToStr(remoteResource.resourceLastChanged!)
		
		return cellView
    }
	
    // MARK: Custom methods
	func fetchDirContents(path:String = "") {
		// path parsing
		var subPath = ServerManager.activeServer.relativePath+path
		if path == "../" {
			// TODO: fix the null keyword -> perhaps some crazy hash
			ServerManager.activeServer.relativePath = (ServerManager.activeServer.relativePath == "" ) ? "null":ServerManager.activeServer.relativePath
			let tmp = NSURL(string: ServerManager.activeServer.relativePath)?.URLByDeletingLastPathComponent
			subPath = (tmp?.absoluteString!)!
			subPath = (subPath == "./") ? "" : subPath
		}
		subPath = (path == "./") ? ServerManager.activeServer.relativePath: subPath
		
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
			let resources = ServerManager.ftpManager.contentsOfServer(ServerManager.activeServer, atLocation: subPath)
			
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				
				self.progress?.hidden = true
				
				if let data:[NSDictionary] = resources as? [NSDictionary] {
					ServerManager.activeServer.relativePath = subPath
					
					self.mRemoteResources = []
					ServerManager.activeServer.relativePath = subPath
					
					for i in data {
						
						let remoteResource = RemoteResource(
							resourceName: i["kCFFTPResourceName"] as String,
							resourceLastChanged: i["kCFFTPResourceModDate"] as NSDate,
							resourceSize: i["kCFFTPResourceSize"] as NSInteger,
							resourceType: i["kCFFTPResourceType"] as NSInteger,
							resourceOwner: i["kCFFTPResourceOwner"] as String,
							resourceMode: i["kCFFTPResourceMode"] as NSInteger)
						self.mRemoteResources.append(remoteResource)
					}
					
					// sorting by folders up top followed by files
					self.mRemoteResources.sort({$0.resourceType < $1.resourceType})
					
					// insert only if server doesn't give us these
					// doing with a quick and dirty check
					if self.mRemoteResources.first?.resourceName != "." {
						self.mRemoteResources.insert(RemoteResource(resourceName: ".", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 0)
						self.mRemoteResources.insert(RemoteResource(resourceName: "..", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 1)
						
					}
					
					
					
					self.fBrowserTableView?.reloadData()
				}

			})
		})
    }
}



class RemoteResourceCellView: NSTableCellView {
    @IBOutlet var resourceTypeIcon:NSImageView!
    @IBOutlet var resourceName:NSTextField!
    @IBOutlet var resourceLastChanged:NSTextField!
}