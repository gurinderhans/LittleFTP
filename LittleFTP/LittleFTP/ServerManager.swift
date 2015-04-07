//
//  ServerManager.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/31/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class ServerManager {
	
	// MARK: public variables
    
	private struct _activerServer { static var server: FMServer = FMServer() }
	class var activeServer: FMServer {
		get { return _activerServer.server }
		set { _activerServer.server = newValue }
	}
	
	private struct _isCreateDirsAndUploadFiles { static var data: Bool = false }
	class var isCreateDirsAndUploadFiles:Bool {
		get { return _isCreateDirsAndUploadFiles.data }
		set { _isCreateDirsAndUploadFiles.data = newValue }
	}
	
	private struct _ftpManager { static var manager: FTPManager = FTPManager() }
	class var ftpManager: FTPManager {
		get { return _ftpManager.manager }
	}
	
    // public func
	class func getAllServers() -> [FMServer] {
		var allServers = [FMServer]()
		
		if let data = NSUserDefaults.standardUserDefaults().objectForKey(AppUtils.localStorageKeys.keyServerUsers.rawValue) as? NSData {
			let serverModels = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [ServerModel]
			for i in serverModels {
				allServers.append(FMServer(
					destination: i.serverURL!,
					onPort: Int32(i.serverPort!),
					username: i.userName!,
					password: i.userPass!))
			}
		}
		
		return allServers
	}

	class var keyServerNameStringVal:String {
		get {
			return (ServerManager.activeServer.destination == nil) ? "" : (ServerManager.activeServer.destination).stripCharactersInSet([".", ":", "/"])
		}
	}
	
    // MARK: self contained function
	
	class func uploadData(localPath pathFrom: String, remotePath pathTo:String) {
		
		// MARK: function declarations with no-op definitions
		var uploadFile: (fQueue:Queue<Dictionary<NSURL, NSURL>>) -> () = { _ in }
		var	createDirsAndUploadFiles: (dirs:Queue<Dictionary<NSURL, NSURL>>, files:Queue<Dictionary<NSURL, NSURL>>) -> () = { _ in }
		
		uploadFile = { flQ in
			if (flQ.isEmpty()) {
				ServerManager.isCreateDirsAndUploadFiles = false
				NSNotificationCenter.defaultCenter().postNotificationName("setOverlay", object: false)
				return
			}
			
			let urlConn = flQ.deQueue()
			
			let localFile = (urlConn?.keys.first)!,
				remoteFile = (urlConn?.values.first?.absoluteString)!
			
			
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
				
				ServerManager.ftpManager.uploadFile(localFile, toServer: ServerManager.activeServer, atLocation: remoteFile)
				
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					uploadFile(fQueue: flQ)
				})
			})
		}
		
		createDirsAndUploadFiles = { dirQ, flQ in
			ServerManager.isCreateDirsAndUploadFiles = true
			if (dirQ.isEmpty()) {
				uploadFile(fQueue: flQ)
			} else {
				let remotePath = dirQ.deQueue()?.values.first!
				
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
					
					//errors for this most likely will be because folder already exists - thus ignore
					ServerManager.ftpManager.createNewFolder(remotePath?.absoluteString!, atServer: ServerManager.activeServer)
					
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						createDirsAndUploadFiles(dirs: dirQ, files: flQ)
					})
				})
				
			}
		}

		
		/**
		* 1. Create all folders [ this will fail if dir exists, but then who cares? ]
		* 2. Start uploading the files [ they get replaced automatically ]
		*/
		
		// establish a new queue <type: dict> for files and folders
		var filesQueue = Queue<Dictionary<NSURL, NSURL>>(),
			foldersQueue = Queue<Dictionary<NSURL, NSURL>>()
		
		let fm = NSFileManager.defaultManager(),
			enumerator:NSDirectoryEnumerator = fm.enumeratorAtPath(pathFrom)!
		
		while let element = enumerator.nextObject() as? String {
			if (element as NSString).containsString(".DS_Store") { continue } // because...
			
			let localURL = NSURL(string: pathFrom)?.URLByAppendingPathComponent(element),
				remoteURL = NSURL(string: pathTo)?.URLByAppendingPathComponent(element)
			
			let attribs: NSDictionary? = fm.attributesOfItemAtPath((localURL?.absoluteString)!, error: nil)
			
			if let fileattribs = attribs {
				let type = fileattribs["NSFileType"] as String
				
				if type == "NSFileTypeRegular" { // file
					filesQueue.enQueue([localURL!:remoteURL!])
				} else if type == "NSFileTypeDirectory" { // directory
					foldersQueue.enQueue([localURL!:remoteURL!])
				}
			}
		}		

		
		if (!ServerManager.isCreateDirsAndUploadFiles) {
			NSNotificationCenter.defaultCenter().postNotificationName("setOverlay", object: true)
			createDirsAndUploadFiles(dirs: foldersQueue, files: filesQueue)
		}
		
	}
}


extension String {
	func stripCharactersInSet(chars: [Character]) -> String {
		return String(filter(self) {find(chars, $0) == nil})
	}
}