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
    
    // TODO: do ftp/sftp decision stuff here
    
    
    //
    // MARK: public class variables
    //
    
    
    private struct _usingServer { static var server: ServerModel = ServerModel() }
    class var usingServer: ServerModel {
        get { return _usingServer.server }
        set { _usingServer.server = newValue }
    }
    
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
    
    
    // @returns - list of servers
    class func allServers() -> [ServerModel] {

        if let data = NSUserDefaults.standardUserDefaults().objectForKey(AppUtils.localStorageKeys.keyServerUsers.rawValue) as? NSData {
            let serverModels = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ServerModel]
            
            return serverModels
        }
        
        return [ServerModel]()
    }
    
    // @returns - list of all servers that the program stores
    class func getAllServers() -> [FMServer] {
        var allServers = [FMServer]()
        
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(AppUtils.localStorageKeys.keyServerUsers.rawValue) as? NSData {
            let serverModels = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ServerModel]
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
    
    // @returns - stripped string of the server name
    class var keyServerNameStringVal:String {
        get {
            // FIXME: returning empty ?
            return (ServerManager.activeServer.destination == nil) ? "" : (ServerManager.activeServer.destination).stripCharactersInSet([".", ":", "/"])
        }
    }
    
    
    
    //
    // MARK: class funcs
    //
    
    
    class func fetchDir(path: String) {
        let server = ServerManager.allServers().last
        
        var host:String? = server?.serverURL?.stringByReplacingOccurrencesOfString("sftp://", withString: "")
        var session: NMSSHSession = NMSSHSession.connectToHost(host, port: (server?.serverPort)!, withUsername: server?.userName)
        
        if session.connected {
            session.authenticateByPassword(server?.userPass)
        } else {
            println("sdfsdf - Not connected")
        }
        
        let response = session.channel.execute("ls -l /var/www", error: nil)
        let folderContents = split(response) {$0 == "\n"}
        for i in folderContents {
            if i.contains("total") == false {
                var resourceArr = split(i) {$0 == " "}
//                RemoteResource(resourceName: resourceArr.last, resourceLastChanged: ServerManager.getResourceDate(resourceArr), resourceSize: (resourceArr[4] == 4096) ? 0 : resourceArr[4], resourceType: <#NSInteger#>, resourceOwner: <#String#>, resourceMode: <#NSInteger#>)
            }
        }
        
        println("\n")
        session.disconnect()
    }
    
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
                
                ServerManager.ftpManager.uploadFile(localFile, toServer: ServerManager.activeServer, atLocation: remoteFile)
                
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
    
    
    class func getResourceDate(resources: [String]) -> NSDate {
        var dt = ",".join(resources[5..<8])
        
        var dtFormat = ""
        if resources[7].contains(":") == true {
            let tmSplit = split(resources[7]) {$0 == ":"}
            if tmSplit.first?.toInt() > 12 {
                dtFormat = "MMM,dd,HH:mm"
            } else {
                dtFormat = "MMM,dd,hh:mm"
            }
            
        } else {
            dtFormat = "MMM,dd,YYYY"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dtFormat
        let date = dateFormatter.dateFromString(dt)
        
        return date!
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