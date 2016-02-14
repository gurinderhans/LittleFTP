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
}