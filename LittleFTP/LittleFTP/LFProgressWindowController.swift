//
//  LFProgressWindowController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/14/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class LFProgressWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility = .Hidden
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeWindow:", name: "closeWindow", object: nil)
    }
    
    func closeWindow(sender: AnyObject?) {
        self.close()
    }
}