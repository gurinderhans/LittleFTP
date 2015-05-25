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
    
    class func makeURL(absolutePath: String, relativePath: String) -> NSURL {
        let serverURL = NSURL(string: absolutePath)?.URLByAppendingPathComponent("")
        var gotoPath = NSURL(string: relativePath, relativeToURL: serverURL)
        return NSURL(string: (gotoPath?.absoluteString?.stringByStandardizingPath)!)!
    }
    
}


struct Storage {
    static let SERVERS = "serverUsers"
    static let CONNECTED_PATH_OBJS = "connectedPathObjs"
    static let ACTIVE_SERVER = "ACTIVE_SERVER"
}