//
//  RemoteFile.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/18/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

class RemoteResource: NSObject {
    
    var resourceName:String?
    var resourceLastChanged:NSDate?
    var resourceSize:NSInteger?
    var resourceType:NSInteger?
    var resourceOwner:String?
    var resourceMode:NSInteger?
    
    init(resourceName: String, resourceLastChanged: NSDate, resourceSize: NSInteger,
        resourceType: NSInteger, resourceOwner: String, resourceMode: NSInteger) {
            
            self.resourceName = resourceName
            self.resourceLastChanged = resourceLastChanged
            self.resourceSize = resourceSize
            self.resourceType = resourceType
            self.resourceOwner = resourceOwner
            self.resourceMode = resourceMode
    }
}