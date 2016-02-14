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
    var modifiedDate:NSDate!
    var type: Int! // resource type, file | folder | etc
    var isFolder: Bool!
    
    override init() {
        super.init()
    }
    
    convenience init(name: String, modDate: NSDate, type: Int) {
        self.init()
        self.name = name
        self.modifiedDate = modDate
        self.type = type
        self.isFolder = type != 8
    }
}