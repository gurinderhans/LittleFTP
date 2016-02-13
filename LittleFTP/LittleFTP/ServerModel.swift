//
//  ServerModel.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/21/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import NMSSH
import FTPManager


class ServerModel: NSObject, NSCoding {

	var serverURL:String? // server IP address
	var serverPort:Int? // port used to make a conn with the server
	var userName:String? // username
    var userPass:String? // password
	var serverState:Int? // is this server currently being used ? 1 (if it is) : 0 (if not)
    var serverType: String? // is server FTP or SFTP ?
    
    // tmp vars only kept in memory
    var serverAbsoluteURL: String = "" // the absolute path for the server where we are currently standing
    var sftp_manager: NMSSHSession?
    var ftp_manager: FTPManager?
    
    // applies mostly to FTP as that blocks the thread, TODO: FTP only?
    var isSpinning: Bool = false
    
    // empty constructor
    override init() {
        super.init()
    }
    
    // custom constructor
	init(serverURL: String, serverPort:Int, userName: String, userPass:String, serverState:Int) {
        super.init()
        
		self.serverURL = serverURL
		self.serverPort = serverPort
        self.userName = userName
		self.userPass = userPass
		self.serverState = serverState
        self.serverType = ServerType.FTP
        
        // set server type to SFTP is it is
        // TODO: check for port too
        if self.serverURL?.uppercaseString.contains(ServerType.SFTP) == true {
            self.serverType = ServerType.SFTP
            
            // also set proper url
            let host: String? = self.serverURL?.stringByReplacingOccurrencesOfString("sftp://", withString: "")
            self.serverURL = host
        }
    }
	
	required init?(coder aDecoder: NSCoder) {
		self.serverURL = aDecoder.decodeObjectForKey(Server.URL) as? String
		self.serverPort = aDecoder.decodeObjectForKey(Server.PORT) as? Int
		self.userName = aDecoder.decodeObjectForKey(Server.UNAME) as? String
		self.userPass = aDecoder.decodeObjectForKey(Server.PASS) as? String
		self.serverState = aDecoder.decodeObjectForKey(Server.STATE) as? Int
        self.serverType = aDecoder.decodeObjectForKey(Server.TYPE) as? String
	}
	
	func encodeWithCoder(coder: NSCoder) {
		coder.encodeObject(self.serverURL, forKey: Server.URL)
		coder.encodeObject(self.serverPort, forKey: Server.PORT)
		coder.encodeObject(self.userName, forKey: Server.UNAME)
		coder.encodeObject(self.userPass, forKey: Server.PASS)
		coder.encodeObject(self.serverState, forKey: Server.STATE)
        coder.encodeObject(self.serverType, forKey: Server.TYPE)
	}
}