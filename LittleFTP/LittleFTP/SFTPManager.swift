//
//  SFTPManager.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2015-05-24.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

class SFTPManager: NSObject {
    
    override init() {
        super.init()
    }
    
    class func getResourceDate(resources: [String]) -> NSDate {
        var dt = ",".join(resources[5..<8])
        
        var dtFormat = ""
        if resources[7].contains(":") == true {
            let tmSplit = split(resources[7]) {$0 == ":"}
            if tmSplit.first?.toInt() > 12 {
                dtFormat = "MMM,dd,HH:mm"
            } else {
                dtFormat = "MMM,dd,hh:mm"
            }
            
        } else {
            dtFormat = "MMM,dd,YYYY"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dtFormat
        let date = dateFormatter.dateFromString(dt)
        
        return date!
    }
    
    
    /**
    Returns the resource type - file || folder
    
    :param: resources An array containg information about the resource such as date, type, name, etc..
    :returns: The type of resource, one of [file, folder]
    */
    class func getResourceType(resources: [String]) -> Int {
        // this gets the perms of the file / folder
        let resourcePerms:String = resources.first!

        let type = resourcePerms[resourcePerms.startIndex]
        
        if type == "d" {
            // type folder
            return 4
        } else {
            // type normal file
            return 8
        }
    }
}