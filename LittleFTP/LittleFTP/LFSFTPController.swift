//
//  LFSFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 4/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

class LFSFTPController {
    
    
    private var _currentSession:NMSSHSession?
    var activeSession:NMSSHSession {
        get {
            if _currentSession == nil {
                _currentSession = NMSSHSession(host: "", andUsername: "")
            }
            return _currentSession!
        }
    }
    
    func readFolder(path:String, atServer server: LFServer) {
    }
}