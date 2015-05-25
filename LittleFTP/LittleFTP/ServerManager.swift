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
    
    
    // @returns - the active server currently being used
    private struct _activeServer { static var server: ServerModel = ServerModel() }
    class var activeServer: ServerModel {
        get { return _activeServer.server }
        set { _activeServer.server = newValue }
    }
    
    // @returns - true if the server is currently working (uploading / downloading files)
    private struct _isSpinning { static var data: Bool = false }
    class var isSpinning:Bool {
        get { return _isSpinning.data }
        set { _isSpinning.data = newValue }
    }
    
    
    // @returns - provied list of all saved servers
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
    
    // progress block
    static var progressBlock:((type: String, progress:Double, filename:String) -> ())!
    
    
    // uploader
    class func uploadData(localPath pathFrom: String, remotePath pathTo:String, onServer server: ServerModel) {
        
        //
        // MARK: function declarations with no-op definitions
        //
        
        var uploadFile: (fQueue:Queue<Dictionary<NSURL, NSURL>>) -> () = { _ in }
        var	createDirs: (dirs:Queue<Dictionary<NSURL, NSURL>>, files:Queue<Dictionary<NSURL, NSURL>>) -> () = { _ in }
        
        
        //
        // MARK: assign operations to functions definitions
        //
        
        
        // iterates through a file queue & uploads each file
        uploadFile = { flQ in
            if (flQ.isEmpty()) {
                ServerManager.isSpinning = false
                NSNotificationCenter.defaultCenter().postNotificationName(Observers.FILE_BROWSER_OVERLAY_PANEL, object: false)
                return
            }
            
            // the file <dict>
            let urlConn = flQ.deQueue()
            
            // get local & remote file URLs
            let localFile = (urlConn?.keys.first)!
            let remoteFile = (urlConn?.values.first?.absoluteString)!
            
            // choose server type
            if server.serverType == ServerType.FTP {
                
                let ftpController = FTPController.sharedController(server)
                ftpController.uploadFile(localFile, toPath: remoteFile, completed: { () -> Void in
                    
                    uploadFile(fQueue: flQ)
                })
                
            } else if server.serverType == ServerType.SFTP {
                //
            }
        }
        
        
        // iterates through a folder queue & creates each folder
        // ** NOTE: this starts the file uploads once the folder queue is empty
        createDirs = { dirQ, flQ in
            
            ServerManager.isSpinning = true
            
            if (dirQ.isEmpty()) {
                
                // start uploading files now
                uploadFile(fQueue: flQ)
                
            } else {
                // get remote path of folder
                let remotePath: NSURL = (dirQ.deQueue()?.values.first)!
            
                // decide which type to use
                if server.serverType == ServerType.FTP {
                    
                    let ftpController = FTPController.sharedController(server)
                    ftpController.createFolder(remotePath.absoluteString!, completed: { success -> Void in
                        println(success)
                        createDirs(dirs: dirQ, files: flQ)
                    })
                    
                } else if server.serverType == ServerType.SFTP {
                    //
                }
            }
        }
        
        
        /**
        * 1. Create all folders [ this will fail if dir exists, but then who cares? ]
        * 2. Start uploading the files [ they get replaced automatically ]
        * 3. TODO: show progress or something while indexing...
        */
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            
            
            //
            // MARK: index through file / folders from in a seperate thread
            //
            
            
            // create a new queue <type: dict> for files and folders
            var filesQueue = Queue<Dictionary<NSURL, NSURL>>(),
            foldersQueue = Queue<Dictionary<NSURL, NSURL>>()
            
            // create an enumerator to index through file paths
            let fm = NSFileManager.defaultManager()
            let enumerator = fm.enumeratorAtPath(pathFrom)!
            
            // start iterating...
            while let element = enumerator.nextObject() as? String {
                
                // we can ignore certain files here
                if (element as NSString).containsString(".DS_Store") { continue } // because...
                
                // create a local & remote url for each element (file / folder)
                let localURL = NSURL(string: pathFrom)?.URLByAppendingPathComponent(element)
                let remoteURL = NSURL(string: pathTo)?.URLByAppendingPathComponent(element)
                
                // get element attributes to check if type is file or folder
                if let attribs = fm.attributesOfItemAtPath((localURL?.absoluteString)!, error: nil) {
                    // the type
                    let type = attribs["NSFileType"] as! String
                    
                    // if type == file add to file queue
                    if type == "NSFileTypeRegular" {
                        filesQueue.enQueue([localURL! : remoteURL!])
                    } else if type == "NSFileTypeDirectory" {
                        // else add to folder queue
                        foldersQueue.enQueue([localURL! : remoteURL!])
                    }
                }
            }
            
            
            
            //
            // MARK: on indexing complete, jump back to main thread
            //
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // we have finished indexing...
                
                // start the upload process if the server is currently
                if (!ServerManager.isSpinning) {
                    NSNotificationCenter.defaultCenter().postNotificationName("setOverlay", object: true)
                    createDirs(dirs: foldersQueue, files: filesQueue)
                }
                
            })
        })
        
    }
    
    
    
}


struct ProgressType {
    static let UPLOAD = "progTypeUpload"
    static let DOWNLOAD = "progTypeDownload"
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