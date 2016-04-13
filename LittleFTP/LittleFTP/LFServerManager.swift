//
//  LFServerManager.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

class LFServerManager {
    
    static let KEY_SERVERS = "allservers"
    
    static var activeServer: LFServer?
    
    static let savedServers: [LFServer] = {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(LFServerManager.KEY_SERVERS) as? NSData {
            if let servers = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [LFServer] {
                return servers
            }
        }
        return []
    }()
    
    
    // TODO: later on with multiple servers at the same time the below variables will change
    
    // SFTP Controller
    static var sftpController = {
        return LFSFTPController(withServer: LFServerManager.activeServer!)
    }()
    
    
    // MARK: - abstract server methods
    
    // FIXME: currently there's no way of knowing if this failed or not
    class func readPath(path:NSURL, files:[LFFile]? -> Void) {
        if LFServerManager.activeServer?.type == .SFTP {
            sftpController.readPath(path, files: files)
        }
    }
    
    class func uploadFiles(files: [LFFile], atPath path: NSURL, progressCb:Int -> Void) {
        if LFServerManager.activeServer?.type == .SFTP {
            // TODO: deal with multiple files upload here
            sftpController.uploadFile(files[0], atPath: path, progressCb: progressCb)
        }
    }
}
