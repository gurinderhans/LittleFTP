//
//  UserModel.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/21/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

let keyServerURL = "serverURL"
let keyServerPort = "serverPort"
let keyUserName = "userName"
let keyUserPass = "userPass"
let keyServerState = "serverState"
let keyServerType = "serverType"

let keyServerTypeFTP = "FTP"
let keyServerTypeSFTP = "SFTP"

class ServerModel: NSObject, NSCoding {

	var serverURL:String?
	var serverPort:Int?
	var userName:String?
    var userPass:String?
	var serverState:Int?
    
    // is server FTP or SFTP ?
    var serverType: String?
    
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
        if self.serverURL?.uppercaseString.contains(keyServerTypeSFTP) == true {
            self.serverType = keyServerTypeSFTP
        } else {
            self.serverType = keyServerTypeFTP
        }
    }
	
	required init(coder aDecoder: NSCoder) {
		self.serverURL = aDecoder.decodeObjectForKey(keyServerURL) as? String
		self.serverPort = aDecoder.decodeObjectForKey(keyServerPort) as? Int
		self.userName = aDecoder.decodeObjectForKey(keyUserName) as? String
		self.userPass = aDecoder.decodeObjectForKey(keyUserPass) as? String
		self.serverState = aDecoder.decodeObjectForKey(keyServerState) as? Int
        self.serverType = aDecoder.decodeObjectForKey(keyServerType) as? String
	}
	
	func encodeWithCoder(coder: NSCoder) {
		coder.encodeObject(self.serverURL, forKey: keyServerURL)
		coder.encodeObject(self.serverPort, forKey: keyServerPort)
		coder.encodeObject(self.userName, forKey: keyUserName)
		coder.encodeObject(self.userPass, forKey: keyUserPass)
		coder.encodeObject(self.serverState, forKey: keyServerState)
        coder.encodeObject(self.serverType, forKey: keyServerType)
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