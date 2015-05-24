//
//  UserModel.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/21/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation


struct Server {
    static let URL          = "serverURL"
    static let PORT         = "serverPort"
    static let UNAME        = "userName"
    static let PASS         = "userPass"
    static let STATE        = "serverState"
    static let TYPE         = "serverType"
    static let ABS_PATH     = "serverAbsolutePath"
}

struct ServerType {
    static let FTP      = "FTP"
    static let SFTP     = "SFTP"
}

class ServerModel: NSObject, NSCoding {

	var serverURL:String? // server IP address
	var serverPort:Int? // port used to make a conn with the server
	var userName:String? // username
    var userPass:String? // password
	var serverState:Int? // is this server currently being used ?
    var serverType: String? // is server FTP or SFTP ?
    var serverAbsoluteURL: String = "" // the absolute path for the server where we are currently standing
    
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
        
        // set server type
        if self.serverURL?.uppercaseString.contains(ServerType.SFTP) == true {
            self.serverType = ServerType.SFTP
        } else {
            self.serverType = ServerType.FTP
        }
    }
	
	required init(coder aDecoder: NSCoder) {
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



//
// MARK: Extensions
//

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}