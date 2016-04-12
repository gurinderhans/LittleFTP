//
//  LFSFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 4/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

class LFSFTPController {
    
    private lazy var activeSession: NMSSHSession? = {
        debugPrint("create session w/ server: \(self.currentServer.hostname), uname: \(self.currentServer.userName)")
        if let tmpSession = NMSSHSession(host: self.currentServer.hostname, port: 22, andUsername: self.currentServer.userName) {
            debugPrint("session: \(tmpSession)")
            debugPrint("session connected: \(tmpSession.connected)")
            
            
            if tmpSession.connected == true {
                tmpSession.authenticateByPassword(self.currentServer.password)
                if tmpSession.authorized { // session validated, this is our session now
                    return tmpSession
                }
            }
        }
        return nil
    }()

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