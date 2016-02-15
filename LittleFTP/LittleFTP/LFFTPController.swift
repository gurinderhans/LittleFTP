//
//  LFFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/14/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import FTPManager

class LFFTPController: NSObject {
    
    lazy var ftpManager = {
        return FTPManager()
    }()
    
    override init() {
        super.init()
    }
}