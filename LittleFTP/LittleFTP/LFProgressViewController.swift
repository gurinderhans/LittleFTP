//
//  LFProgressViewController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/14/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
import Cocoa

class LFProgressViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploadfiles:", name: "uploadfiles", object: nil)
    }
    
    // MARK: - Selector methods
    
    func uploadfiles(sender: AnyObject!) {
        print("upload files: \(sender.object)")
    }
    
}