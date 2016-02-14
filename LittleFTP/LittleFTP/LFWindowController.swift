//
//  LFWindowController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Cocoa

class LFWindowController: NSWindowController {

    @IBOutlet weak var windowProgressField: NSView!
    
    @IBAction func navButtonsClicked(nav:NSSegmentedControl!){
        NSNotificationCenter.defaultCenter().postNotificationName("navigationChanged", object: nav.selectedSegment)
    }
    
    lazy var filenameLabel:NSTextView = {
        let aLabel = NSTextView(frame: NSRect(x: 0, y: 7.5, width: self.windowProgressField.frame.width, height: 1))
            aLabel.alignment = .Center
            aLabel.editable = false
            aLabel.selectable = false
            aLabel.backgroundColor = NSColor(calibratedRed: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
            aLabel.font = NSFont.systemFontOfSize(13, weight: 0.1)
            aLabel.textColor = NSColor(calibratedWhite: 0.2, alpha: 1.0)
            aLabel.backgroundColor = NSColor(calibratedWhite: 0, alpha: 0)
            self.windowProgressField.addSubview(aLabel)
        return aLabel
    }()
    
    lazy var fileProgress: NSProgressIndicator = {
        let pIn = NSProgressIndicator(frame: NSRect(x: 0, y: self.windowProgressField.frame.height - 7, width: self.windowProgressField.frame.width, height: 2))
            pIn.indeterminate = false
            pIn.incrementBy(1)
            self.windowProgressField.addSubview(pIn)
        return pIn
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.titleVisibility = .Hidden
        
        NSNotificationCenter.defaultCenter().postNotificationName("progressAreaReady", object: [filenameLabel, fileProgress])
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateWindowProgressField:", name: "updateWindowProgressField", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateWindowProgressBar:", name: "updateWindowProgressBar", object: nil)
    }
//    
//    // MARK: - Selector methods
//    func updateWindowProgressField(sender: AnyObject!) {
//        if let currentUploadingFileUrl = sender.object as? String {
//            filenameLabel.string = currentUploadingFileUrl
//        }
//    }
//    
//    func updateWindowProgressBar(sender: AnyObject!) {
//        fileProgress.doubleValue = Double(sender.object as! Int)
//    }

}
