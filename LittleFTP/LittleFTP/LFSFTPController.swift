//
//  LFSFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 4/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

class LFSFTPController {
    
    // https://github.com/gurinderhans/LittleFTP/commit/3476017fbc5e84355aba81a5789d511b83d76c10
    // lazy var propery isn't good here, in case session connect fails, we won't be able to try connecting again
    private lazy var activeSession: NMSSHSession? = {
        debugPrint("create session w/ server: \(self.currentServer.hostname), uname: \(self.currentServer.userName)")
        if let tmpSession = NMSSHSession(host: self.currentServer.hostname, port: 22, andUsername: self.currentServer.userName) {
            tmpSession.connect()
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
    
    func readPath(path:NSURL, files:[LFFile]? -> Void) {
        debugPrint(#function)
        do {
            
            let resp = try activeSession?.channel.execute(SSHDataCreator.lsCmd(path.absoluteString))
            let parsedFiles = resp!.characters.split{$0 == "\n"}.map(String.init).map ({ a -> LFFile in
                return LFFile(parseSSHData: a)
            }).filter({ a -> Bool in
                return a.name != nil
            })
            
            
            files(parsedFiles)
        } catch let error as NSError  {
            debugPrint("err: \(error)")
        }
    }
    
    func uploadFile(file: LFFile, atPath path: NSURL, progressCb:Int -> Void) -> Bool {
        
        debugPrint("file: \(file.filePath), to: \(path)")
        activeSession?.channel.uploadFile(file.filePath, to: path.absoluteString, progress: { i -> Bool in
            debugPrint("rawProgress: \(i)")
            progressCb(Int(i))
            return true
        })
        
        return false
    }
}

class SSHDataCreator {
    class func lsCmd(dir:String) -> String {
        return "ls -la \(dir) | awk '{print \"{\\\"name\\\":\\\"\"$9\"\\\",\\\"size\\\":\"$5\",\\\"perms\\\":\\\"\"$1\"\\\"}\"}'"
    }
}