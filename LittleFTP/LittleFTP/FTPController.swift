//
//  FTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2015-05-24.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import FTPManager

class FTPController {

    private static var instance: FTPController!
    
    var ftpServer: FMServer!
    var ftpManager: FTPManager!
    
    // SHARED INSTANCE
    class func sharedController(server: ServerModel) -> FTPController {
        // create instance
        if self.instance == nil {
            self.instance = FTPController()
            
            // assign ftp server
            self.instance.ftpServer = FMServer(destination: server.serverURL, username: server.userName, password: server.userPass)
            
            // assign ftp manager
            self.instance.ftpManager = FTPManager()
        }
        
        // return instance
        return self.instance
    }
    
    init() {
        print(__FUNCTION__)
    }
    
    
    func fetchDir(path:String, completed: ([RemoteResource]) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            // fetch in background
            let response = self.ftpManager.contentsOfServer(self.ftpServer)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                if let data:[NSDictionary] = response as? [NSDictionary] {
                    
                    var fetchedResources = [RemoteResource]()
                    
                    for i in data {
                        
                        let remoteResource = RemoteResource(
                            resourceName: i["kCFFTPResourceName"] as! String,
                            resourceLastChanged: i["kCFFTPResourceModDate"] as! NSDate,
                            resourceSize: i["kCFFTPResourceSize"] as! NSInteger,
                            resourceType: i["kCFFTPResourceType"] as! NSInteger,
                            resourceOwner: i["kCFFTPResourceOwner"] as! String,
                            resourceMode: i["kCFFTPResourceMode"] as! NSInteger)
                        
                        fetchedResources.append(remoteResource)
                    }
                    
                    // insert only if server doesn't give us these, TODO: check using a better method
                    if fetchedResources.first?.resourceName != "." {
                        fetchedResources.insert(RemoteResource(resourceName: ".", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 0)
                        fetchedResources.insert(RemoteResource(resourceName: "..", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 1)
                    }
                    
                    // on fetching complete
                    completed(fetchedResources)
                }
            })
        })
    }
    
    func uploadFile(filePath: NSURL, toPath path: String, completed: () -> Void) {
        // upload file
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            
            // upload the file
//            self.ftpManager.uploadFile(filePath, toServer: self.ftpServer, atLocation: path)
            
            // assign a progress listener
//            self.ftpManager.onProgress = { totalProgress, fileName in
//                ServerManager.progressBlock(type: ProgressType.UPLOAD, progress: totalProgress, filename: fileName)
//            }
            
            // call completion block on complete
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completed()
            })
        })
    }
    
    func createFolder(folderPath: String, completed: (Bool) -> Void) {
        // create folder
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            
            // errors for this most likely will be because folder already exists - thus ignore
            let uploaded = self.ftpManager.createNewFolder(folderPath, atServer: self.ftpServer)

            // once done call completion block
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completed(uploaded)
            })
        })

    }
    
    
    func downloadFile(filePath: String) {
        // download file
    }
    
    func deleteFile(filePath: String) {
        // delete file
    }
    
    func deleteFolder(folderPath: String) {
        // delete folder
    }
}