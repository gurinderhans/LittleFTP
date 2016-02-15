//
//  LFServerManager.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import FTPManager

class LFServerManager: NSObject {
    
    private static var _activeServer: FMServer?
    class var activeServer: FMServer? {
        get {
            if let s = _activeServer {
                return s
            }
            return nil
        }
        set {
            _activeServer = newValue
        }
    }
    
    static var ftpManager: FTPManager = {
        return FTPManager()
    }()
    
    // MARK: - Any server methods
    
    class func uploadFile(id:Int) {
        print("starting new thread w/ ID: \(id)")
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            let url = NSURL(string: (LFServerManager.activeServer?.destination)!)
            LFServerManager.activeServer?.destination = (url?.URLByAppendingPathComponent("test", isDirectory: true))!.absoluteString
            FTPManager().uploadFile(NSURL(string: "/Users/ghans/Desktop/testzip5-\(id).zip"), toServer: LFServerManager.activeServer)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("finished w/ ID:\(id)")
            })
        })
    }
}