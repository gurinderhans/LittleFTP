//
//  ConnectedPathModel.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/21/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

let keyIsEnabled = "isEnabled"
let keyLocalPath = "localPath"
let keyRemotePath = "remotePath"


class ConnectedPathModel: NSObject, NSCoding {
    var isEnabled:Bool?
    var localPath:String?
    var remotePath:String?
    
    init(isEnabled:Bool, localPath:String, remotePath:String) {
        self.isEnabled = isEnabled
        self.localPath = localPath
        self.remotePath = remotePath
    }
	
	required init?(coder aDecoder: NSCoder) {
		self.isEnabled = aDecoder.decodeBoolForKey(keyIsEnabled)
		self.localPath = aDecoder.decodeObjectForKey(keyLocalPath) as? String
		self.remotePath = aDecoder.decodeObjectForKey(keyRemotePath) as? String
	}
	
	func encodeWithCoder(coder: NSCoder) {
		coder.encodeBool(self.isEnabled!, forKey: keyIsEnabled)
		coder.encodeObject(self.localPath, forKey: keyLocalPath)
		coder.encodeObject(self.remotePath, forKey: keyRemotePath)
	}
    
}