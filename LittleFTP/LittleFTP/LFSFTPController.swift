//
//  LFSFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 4/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import NMSSH

class LFSFTPController {
    
    var aClient:String {
        get {
            if((_aClient == nil)) {
//                _aClient = Client(ClientSession.shared())
            }
            return _aClient!
        }
    }
    
    var _aClient:String?
    
    func readFolder(path:String, atServer server: LFServer) {
//        NMSSHSession
    }
}