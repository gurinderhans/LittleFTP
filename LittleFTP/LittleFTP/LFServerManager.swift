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
    
    // current session url of the server
    var activeUrl: NSURL!
    
    
    // MARK: - abstract server methods
    
    class func openFolder(withName name:String, files:[LFFile]? -> Void) {
        if LFServerManager.activeServer?.type == .SFTP {
//            ftpController.listServerFolder(name, files: files)
        }
    }
    
    class func uploadFile(file: NSURL, finish: Bool -> (), cb: ([NSObject: AnyObject] -> ())?) {
        print(#function)
        if LFServerManager.activeServer?.type == .SFTP {
//            ftpController.uploadFile(file, finish: finish, progCb: cb)
        }
    }
}
