//
//  LFServer.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

struct LFServerKeys {
    static let HOSTNAME = "hostname"
    static let PORT = "port"
    static let USERNAME = "username"
    static let PASSWORD = "password"
}

enum ServerTypes {
    case FTP
    case SFTP
}

class LFServer: NSObject, NSCoding {
    
    // encoded vars
    var hostname: String!
    var port: String!
    var userName: String!
    var password: String!
    
    // tmp vars
    var activeUrl: NSURL!

    // TODO: - this will be computed once multiple types are supported
    var type:ServerTypes = .FTP
    
    override init() {
        super.init()
    }
    
    convenience init(url: String, port:String, uname: String, pass:String) {
        self.init()
        self.hostname = url
        self.port = port
        self.userName = uname
        self.password = pass
        self.activeUrl = NSURL(string: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.hostname = aDecoder.decodeObjectForKey(LFServerKeys.HOSTNAME) as! String
        self.port = aDecoder.decodeObjectForKey(LFServerKeys.PORT) as! String
        self.userName = aDecoder.decodeObjectForKey(LFServerKeys.USERNAME) as! String
        self.password = aDecoder.decodeObjectForKey(LFServerKeys.PASSWORD) as! String
        self.activeUrl = NSURL(string: self.hostname)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.hostname, forKey: LFServerKeys.HOSTNAME)
        coder.encodeObject(self.port, forKey: LFServerKeys.PORT)
        coder.encodeObject(self.userName, forKey: LFServerKeys.USERNAME)
        coder.encodeObject(self.password, forKey: LFServerKeys.PASSWORD)
    }
}