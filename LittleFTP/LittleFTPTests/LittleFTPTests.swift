//
//  LittleFTPTests.swift
//  LittleFTPTests
//
//  Created by Gurinder Hans on 2/12/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import XCTest
@testable import LittleFTP

class LittleFTPTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLFServerMostForwardedURLValue() {
        let server = LFServer()
        
        // test if initial equal
        server.currentStandingUrl = NSURL(string: "/some/url/pathto/folder/")?.URLByAppendingPathComponent("somedirectory", isDirectory: true)
        XCTAssertEqual(server.currentStandingUrl.absoluteString, server.mostFowardedUrl.absoluteString)
        
        // test if going back works
        server.currentStandingUrl = server.currentStandingUrl.URLByDeletingLastPathComponent
        XCTAssertNotEqual(server.currentStandingUrl.absoluteString, server.mostFowardedUrl.absoluteString)
        
        // test if going forward works
        XCTAssertEqual(server.currentStandingUrl.URLByAppendingPathComponent(server.mostFowardedUrl.lastPathComponent!, isDirectory: true).absoluteString, server.mostFowardedUrl.absoluteString)
    }
    
    func testLFFileinits() {
        let fl = LFFile(parseSSHData: "{\"name\":\"testMyName\", \"size\":311, \"perms\":\"drw\"}")
        XCTAssertEqual(fl.name, "testMyName")
        XCTAssertEqual(fl.size, 311)
        XCTAssertTrue(fl.isFolder)
        
        let fl1 = LFFile(filePath: "/Users/ghans/Documents/SFU/CMPT 276/cmpt276-projects/ex1/submit.txt")
        XCTAssertNotEqual(fl1.filePath, nil)
        XCTAssertEqual(fl1.name, "submit.txt")
        
    }
    
    func testLFServerEncodingAndDecoding() {
        //
    }
    
}
