//
//  LFFile.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/13/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation

class LFFile: NSObject {
    var name:String!
    var filePath: String!
    var modifiedDate:NSDate = NSDate()
    var isFolder: Bool!
    var size: UInt64!
    
    init(parseSSHData data:String) {
        if let datas = data.dataUsingEncoding(NSUTF8StringEncoding),
            let json = try? NSJSONSerialization.JSONObjectWithData(datas, options: .AllowFragments),
            let name = json["name"] as? String,
            let perms = json["perms"] as? String,
            let size = json["size"] as? Int {
            
            self.name = name
            self.isFolder = perms[perms.startIndex] == "d"
            self.size = UInt64(size)
        }
    }
    
    init(filePath: String, size: UInt64) {
        self.filePath = filePath
        
        self.name = NSURL(string: filePath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!.lastPathComponent
        
        self.isFolder = false
        self.size = size
    }
    
    override init() {
        super.init()
    }
}