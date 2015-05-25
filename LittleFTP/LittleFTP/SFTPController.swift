//
//  SFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2015-05-24.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

class SFTPController {
    
    private static var instance: SFTPController!
    
    var sftpServer: NMSSHSession!
    
    // SHARED INSTANCE
    class func sharedController(server: ServerModel) -> SFTPController {
        // create instance
        if self.instance == nil {
            self.instance = SFTPController()
            
            // assign ssh server
            let host: String? = server.serverURL?.stringByReplacingOccurrencesOfString("sftp://", withString: "")
            self.instance.sftpServer = NMSSHSession.connectToHost(host, port: server.serverPort!, withUsername: server.userName)
            if self.instance.sftpServer.connected {
                self.instance.sftpServer.authenticateByPassword(server.userPass)
            }
        }

        
        // return instance
        return self.instance
    }
    
    init() {
        println(__FUNCTION__)
    }
    
    
    func fetchDir(path:String, completed: ([RemoteResource]) -> Void) {
        // fetch dir
        
        let response = self.sftpServer.channel.execute("ls -al \(path)", error: nil)
        
        println(response)
        
        // FIXME: how to check for no response ?
        if response != "" {
            
            var fetchedResources = [RemoteResource]()
            
            var folderContents = split(response) {$0 == "\n"}
            
            if folderContents.first?.contains("total") == true { folderContents.removeAtIndex(folderContents.startIndex) }
            
            for i in folderContents {
                let resourceArr = split(i) {$0 == " "}
                
                let sz = (resourceArr[4].toInt() == 4096) ? 1 : 0
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
//        session.disconnect()

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