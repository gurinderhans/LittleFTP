//
//  LFSFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 4/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

class LFSFTPController {
    
    private var _activeSession:NMSSHSession? // active session storage
    private var activeSession: NMSSHSession? {
        if _activeSession == nil {
            debugPrint("create session w/ server: \(currentServer.hostname), uname: \(currentServer.userName)")
            if let tmpSession = NMSSHSession(host: currentServer.hostname, port: 22, andUsername: currentServer.userName) {
                debugPrint("session: \(tmpSession)")
                debugPrint("session connected: \(tmpSession.connected)")
                
                
                if tmpSession.connected == true {
                    tmpSession.authenticateByPassword(currentServer.password)
                    if tmpSession.authorized { // session validated, this is our session now
                        _activeSession = tmpSession
                        return tmpSession
                    }
                }
            }
        }
        
        return _activeSession
    }

    private var currentServer: LFServer!
    
    init(withServer server: LFServer) {
        currentServer = server
    }
    
    func readFolder(path:String, atServer server: LFServer) {
        debugPrint(#function)
        debugPrint("activeSession: \(activeSession)")
//        do {
//            debugPrint("activeSession: \(activeSession)")
//            let resp = try activeSession?.channel.execute("ls -l /")
//            debugPrint("resp: \(resp)")
//        } catch let error as NSError  {
//            debugPrint("err: \(error)")
//        }
    }
}