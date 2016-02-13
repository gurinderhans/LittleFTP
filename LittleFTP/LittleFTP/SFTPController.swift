//
//  SFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2015-05-24.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import NMSSH

class SFTPController {
    
    private static var instance: SFTPController!
    
    private var sftpServer: NMSSHSession!
    
    // SHARED INSTANCE
    class func sharedController(server: ServerModel) -> SFTPController {
        // create instance
        if self.instance == nil {
            self.instance = SFTPController()
            
            // assign ssh server
            self.instance.sftpServer = NMSSHSession.connectToHost(server.serverURL, port: server.serverPort!, withUsername: server.userName)
            if self.instance.sftpServer.connected {
                self.instance.sftpServer.authenticateByPassword(server.userPass)
            }
        }

        
        // return instance
        return self.instance
    }
    
    init() {
        print(__FUNCTION__)
    }
    
    
    func fetchDir(path:String, completed: ([RemoteResource]) -> Void) {
        // fetch dir
        let response = try? self.sftpServer.channel.execute("ls -al \(path)")
        
        // FIXME: how to check for no response ?
        if response != "" {
            
            var fetchedResources = [RemoteResource]()
            
            var folderContents = response?.characters.split {$0 == "\n"}.map { String($0) }
            
            if folderContents?.first?.contains("total") == true {
                folderContents?.removeAtIndex(folderContents!.startIndex)
            }
            
            for i in (folderContents)! {
                let resourceArr = i.characters.split {$0 == " "}.map { String($0) }
                
                let sz = (Int(resourceArr[4]) == 4096) ? 1 : 0
                let createdResource = RemoteResource(
                    resourceName: resourceArr.last!,
                    resourceLastChanged: SFTPManager.getResourceDate(resourceArr),
                    resourceSize: sz,
                    resourceType: SFTPManager.getResourceType(resourceArr),
                    resourceOwner: resourceArr[2],
                    resourceMode: -1)
                
                fetchedResources.append(createdResource)
            }
            
            // insert only if server doesn't give us these, TODO: check using a better method
            if fetchedResources.first?.resourceName != "." {
                fetchedResources.insert(RemoteResource(resourceName: ".", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 0)
                fetchedResources.insert(RemoteResource(resourceName: "..", resourceLastChanged: NSDate(), resourceSize: 0, resourceType: 4, resourceOwner: "", resourceMode: 0), atIndex: 1)
            }
            
            // on fetching complete
            completed(fetchedResources)
        }
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
    
    func createFolder(folderPath: String, completed: (Bool) -> Void) {
        // create folder
        
        completed(true)
    }
    
    func deleteFolder(folderPath: String) {
        // delete folder
    }
}