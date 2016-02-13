//
//  LittleFTPWindowController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Cocoa
import INAppStoreWindow

class LittleFTPWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let aWindow = self.window as? INAppStoreWindow {
            aWindow.titleBarHeight = 50
            aWindow.titleBarStartColor = NSColor(calibratedWhite: 0.75, alpha: 1.0)
            aWindow.titleBarEndColor = NSColor(calibratedWhite: 0.85, alpha: 1.0)
            aWindow.baselineSeparatorColor = NSColor(calibratedWhite: 0.6, alpha: 1.0)
        }
    }

}
