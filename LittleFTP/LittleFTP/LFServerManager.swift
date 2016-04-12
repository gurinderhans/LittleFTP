//
//  LFServerManager.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

class LFServerManager: NSObject {
    
    private static var _activeServer: LFServer?
    class var activeServer: LFServer? {
        get {
            if let s = _activeServer {
                return s
            } else {
                return nil
            }
        }
        set {
            _activeServer = newValue
        }
    }
    
//    static var ftpController = {
//        return LFFTPController()
//    }()
    
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
