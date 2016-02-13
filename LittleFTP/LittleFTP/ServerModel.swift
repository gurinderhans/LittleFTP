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

	var serverURL:String! // server IP address
	var serverPort:String! // port used to make a conn with the server
	var userName:String! // username
    var userPass:String! // password
    var serverType: String! // FTP or SFTP or Whatever...
    var serverState:Int! // is this server currently being used ? 1 (if it is) : 0 (if not)
    
    // tmp vars only kept in memory
    var serverAbsoluteURL: String = "" // the absolute path for the server where we are currently standing
    var sftp_manager: NMSSHSession?
    var ftp_manager: FTPManager?
    
    // applies mostly to FTP server as they are synchrounous
    var isSpinning: Bool = false
    
    // empty constructor
    override init() {
        super.init()
    }
    
    // custom constructor
	convenience init(host: String, port:String, uname: String, pass:String) {
        self.init()
		self.serverURL = host
		self.serverPort = port
        self.userName = uname
		self.userPass = pass
    }
	
	required init?(coder aDecoder: NSCoder) {
		self.serverURL = aDecoder.decodeObjectForKey(Server.URL) as? String
		self.serverPort = aDecoder.decodeObjectForKey(Server.PORT) as? String
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