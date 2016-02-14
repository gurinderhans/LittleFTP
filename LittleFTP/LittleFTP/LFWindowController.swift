//
//  LFWindowController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Cocoa

class LFWindowController: NSWindowController {
    
    @IBAction func navButtonsClicked(nav:NSSegmentedControl!){
        NSNotificationCenter.defaultCenter().postNotificationName("navigationChanged", object: nav.selectedSegment)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.titleVisibility = .Hidden
    }

}
