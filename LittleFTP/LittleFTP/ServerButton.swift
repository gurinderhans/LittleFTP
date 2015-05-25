//
//  ServerButton.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 4/5/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class ServerButton: NSButton {
	override func rightMouseDown(theEvent: NSEvent) {
		let view = self as NSView
        println("cl")
		NSNotificationCenter.defaultCenter().postNotificationName("switchRClick", object: view)
	}
}