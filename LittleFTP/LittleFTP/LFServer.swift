//
//  LFServer.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

class LFServer: NSObject, NSCoding {
    
    // encoded vars
    var hostname: String!
    var port: String!
    var userName: String!
    var password: String!
    var sshKey: String? // TODO: support using key to authenticate
    
    // mem vars
    var currentStandingUrl: NSURL! = NSURL(string: "/") {
        didSet {
            if let currentComponents = currentStandingUrl.pathComponents,
                let forwardedComponents = mostFowardedUrl.pathComponents {
                if currentComponents.count < forwardedComponents.count {
                    // URL is either behind or on a new path
                    var isNewUrl: Bool = false
                    for (idx, el) in currentComponents.enumerate() {
                        if el != forwardedComponents[idx] {
                            isNewUrl = true
                        }
                    }
                    if isNewUrl == true {
                        mostFowardedUrl = currentStandingUrl
                    }
                } else {
                    mostFowardedUrl = currentStandingUrl
                }
            }
        }
    }
    var mostFowardedUrl: NSURL! = NSURL(string: "/") // the furthest deep the server was browsed

    // TODO: - this will be encoded and computed once multiple types are supported
    var type:ServerTypes = .SFTP
    
    override init() {
        super.init()
    }
    
    convenience init(url: String, port:String, uname: String, pass:String) {
        self.init()
        self.hostname = url
        self.port = port
        self.userName = uname
        self.password = pass
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.hostname = aDecoder.decodeObjectForKey(LFServerKeys.HOSTNAME) as! String
        self.port = aDecoder.decodeObjectForKey(LFServerKeys.PORT) as! String
        self.userName = aDecoder.decodeObjectForKey(LFServerKeys.USERNAME) as! String
        self.password = aDecoder.decodeObjectForKey(LFServerKeys.PASSWORD) as! String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.hostname, forKey: LFServerKeys.HOSTNAME)
        coder.encodeObject(self.port, forKey: LFServerKeys.PORT)
        coder.encodeObject(self.userName, forKey: LFServerKeys.USERNAME)
        coder.encodeObject(self.password, forKey: LFServerKeys.PASSWORD)
    }
}

enum ServerTypes {
    case FTP
    case SFTP
}