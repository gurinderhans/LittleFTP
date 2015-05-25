//
//  AppUtils.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/23/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

class AppUtils {
	
    class func dateToStr(date:NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EE hh:mm a dd/yy"
        return formatter.stringFromDate(date)
    }
    
    class func parseServerURL(relativePath pathA: String, clickedItemPath pathB: String) ->String {
        var subPath = pathA+pathB
        
        if pathB == ".." {
            
            // TODO: fix the null keyword -> perhaps some crazy hash
            let tmppath = (pathA == "" ) ? "null":pathA,
				tmp = NSURL(string: tmppath)?.URLByDeletingLastPathComponent
            
            subPath = (tmp?.absoluteString!)!
            subPath = (subPath == ".") ? "" : subPath
        }
        
        subPath = (pathB == ".") ? pathA: subPath + "/"
        subPath = (subPath == ".//") ? "/" : subPath
        subPath = (subPath == "") ? "/" : subPath
        
        return subPath
    }
    
}


struct Storage {
    static let SERVERS = "serverUsers"
    static let CONNECTED_PATH_OBJS = "connectedPathObjs"
    static let ACTIVE_SERVER = "ACTIVE_SERVER"
}