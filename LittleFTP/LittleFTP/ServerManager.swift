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
    
    //
    // MARK: public class variables
    //
    
    
    private struct _activeServer { static var server: ServerModel = ServerModel() }
    class var activeServer: ServerModel {
        get { return _activeServer.server }
        set { _activeServer.server = newValue }
    }
    
    private struct _isCreateDirsAndUploadFiles { static var data: Bool = false }
    class var isCreateDirsAndUploadFiles:Bool {
        get { return _isCreateDirsAndUploadFiles.data }
        set { _isCreateDirsAndUploadFiles.data = newValue }
    }
    
    
    // @returns - list of all created servers
    class func allServers() -> [ServerModel] {

        if let data = NSUserDefaults.standardUserDefaults().objectForKey(Storage.SERVERS) as? NSData {
            let serverModels = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ServerModel]
            
            return serverModels
        }
        
        return [ServerModel]()
    }
    
    // @returns - stripped string of the server name
    class var keyServerNameStringVal:String {
        get {
            // FIXME: returning empty ?
            return (ServerManager.activeServer.serverURL == nil) ? "" : (ServerManager.activeServer.serverURL)!.stripCharactersInSet([".", ":", "/"])
        }
    }
    
    
    
    //
    // MARK: class funcs
    //
    
    
    /**
    Reads contents of a folder
    
    :param: path The folder path to read from
    :param: onFetched The completion block, gets called when we have fetched the read data
    :returns: List<RemoteResources> containing the read contents
    */
    
    class func list_directory(path: String, ofServer server: ServerModel, onFetched: ([RemoteResource]) -> Void) {
        if server.serverType == ServerType.FTP {
            
            // create controller from the server
            let ftp = FTPController.sharedController(server)
            // fetch
            ftp.fetchDir(path, completed: onFetched)

        } else if server.serverType == ServerType.SFTP {
            
            // create controller from the server
            let sftp = SFTPController.sharedController(server)
            // fetch
            sftp.fetchDir(path, completed: onFetched)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    class func fetchDir(path: String, onFetched: ([RemoteResource]) -> Void) {
//        
//        // fetched resources from server
//        var fetchedResources = [RemoteResource]() // we return this
//        
//        if ServerManager.activeServer.serverType == ServerType.FTP { // FTP fetching
//            
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
//                
//                // fetch dir content
////                let resources = ServerManager.ftpManager.contentsOfServer(ServerManager.usingS, atLocation: path)
////                
////                dispatch_async(dispatch_get_main_queue(), { () -> Void in
////                    // finished fetching
////                    if let data:[NSDictionary] = resources as? [NSDictionary] {
////                        
////                        ServerManager.usingServer.serverAbsoluteURL = path
////                        
////                        for i in data {
////                            let remoteResource = RemoteResource(
////                                resourceName: i["kCFFTPResourceName"] as! String,
////                                resourceLastChanged: i["kCFFTPResourceModDate"] as! NSDate,
////                                resourceSize: i["kCFFTPResourceSize"] as! NSInteger,
////                                resourceType: i["kCFFTPResourceType"] as! NSInteger,
////                                resourceOwner: i["kCFFTPResourceOwner"] as! String,
////                                resourceMode: i["kCFFTPResourceMode"] as! NSInteger)
////                            
////                            fetchedResources.append(remoteResource)
////                            
////                        }
////                        
////                        // send resources to the other side
////                        onFetched(fetchedResources)
////                    }
////                    
////                })
//            })
//        } else { // SFTP fetching
//            
//            let response = ServerManager.activeServer.sftp_manager!.channel.execute("ls -al \(path)", error: nil)
//            println(response)
//            if response != "" { // FIXME: how to check for no response ?
//                
//                ServerManager.activeServer.serverAbsoluteURL = path
//                
//                var folderContents = split(response) {$0 == "\n"}
//                
//                if folderContents.first?.contains("total") == true {
//                    folderContents.removeAtIndex(folderContents.startIndex)
//                }
//                
//                for i in folderContents {
//                    let resourceArr = split(i) {$0 == " "}
//                    
//                    let sz = (resourceArr[4].toInt() == 4096) ? 1 : 0
//                    let createdResource = RemoteResource(
//                        resourceName: resourceArr.last!,
//                        resourceLastChanged: SFTPManager.getResourceDate(resourceArr),
//                        resourceSize: sz,
//                        resourceType: SFTPManager.getResourceType(resourceArr),
//                        resourceOwner: resourceArr[2],
//                        resourceMode: -1)
//                    
//                    fetchedResources.append(createdResource)
//                }
//                
//                onFetched(fetchedResources)
//            }
////            session.disconnect()
//            // insert only if server doesn't give us these
//            // doing with a quick and dirty check
////            if self.mRemoteResources.first?.resourceName != "." {
////                self.mRemoteResources.insert(RemoteResource(resourceName: ".", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 0)
////                self.mRemoteResources.insert(RemoteResource(resourceName: "..", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 1)
////            }
//
//        }
//    }
    
    
    
    class func uploadData(localPath pathFrom: String, remotePath pathTo:String) {
        
        //
        // MARK: function declarations with no-op definitions
        //
        
        var uploadFile: (fQueue:Queue<Dictionary<NSURL, NSURL>>) -> () = { _ in }
        var	createDirsAndUploadFiles: (dirs:Queue<Dictionary<NSURL, NSURL>>, files:Queue<Dictionary<NSURL, NSURL>>) -> () = { _ in }
        
        
        //
        // MARK: assign operations to functions definitions
        //
        
        
        // iterates through a file queue & uploads each file
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
                
//                ServerManager.ftpManager.uploadFile(localFile, toServer: ServerManager.activeServer, atLocation: remoteFile)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    uploadFile(fQueue: flQ)
                })
            })
        }
        
        
        // iterates through a folder queue & creates each folder
        // ** NOTE: this starts the file uploads once the folder queue is emptied
        createDirsAndUploadFiles = { dirQ, flQ in
            ServerManager.isCreateDirsAndUploadFiles = true
            if (dirQ.isEmpty()) {
                uploadFile(fQueue: flQ)
            } else {
                let remotePath = dirQ.deQueue()?.values.first!
                
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                    
                    //errors for this most likely will be because folder already exists - thus ignore
//                    ServerManager.ftpManager.createNewFolder(remotePath?.absoluteString!, atServer: ServerManager.activeServer)
                    
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
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            
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
                    let type = fileattribs["NSFileType"] as! String
                    
                    if type == "NSFileTypeRegular" { // file
                        filesQueue.enQueue([localURL!:remoteURL!])
                    } else if type == "NSFileTypeDirectory" { // directory
                        foldersQueue.enQueue([localURL!:remoteURL!])
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // start the upload process
                if (!ServerManager.isCreateDirsAndUploadFiles) {
                    NSNotificationCenter.defaultCenter().postNotificationName("setOverlay", object: true)
                    createDirsAndUploadFiles(dirs: foldersQueue, files: filesQueue)
                }
                
            })
        })
        
    }
    
    
    
}



//
// MARK: Extensions
//


// custom String.class extension
extension String {
    
    // removes all given characters from string
    func stripCharactersInSet(chars: [Character]) -> String {
        return String(filter(self) {find(chars, $0) == nil})
    }
}