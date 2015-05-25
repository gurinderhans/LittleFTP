//
//  FTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2015-05-24.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

class FTPController {
    
    //
    //
    //
    
    private static var instance: FTPController!
    
    var ftpServer: FMServer!
    var ftpManager: FTPManager!
    
    // SHARED INSTANCE
    class func sharedController(server: ServerModel) -> FTPController {
        // create instance
        if self.instance == nil {
            self.instance = FTPController()
            
            // assign ftp server
            self.instance.ftpServer = FMServer(destination: server.serverURL!, onPort: Int32(server.serverPort!), username: server.userName!, password: server.userPass!)
            
            // assign ftp manager
            self.instance.ftpManager = FTPManager()
        }
        
        // return instance
        return self.instance
    }
    
    init() {
        println(__FUNCTION__)
    }
    
    
    func fetchDir(path:String, completed: ([RemoteResource]) -> Void) {
        // fetch dir
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            // fetch in background
            let response = self.ftpManager.contentsOfServer(self.ftpServer, atLocation: path)
            
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
                    completed([RemoteResource]())
                }
            })
        })
    }
    
    func uploadFile(file: RemoteResource) {
        // upload file
    }
    
    func downloadFile(filePath: String) {
        // download file
    }
    
    func deleteFile(filePath: String) {
        // delete file
    }
    
    func createFolder(folderPath: String) {
        // create folder
    }
    
    func deleteFolder(folderPath: String) {
        // delete folder
    }
}