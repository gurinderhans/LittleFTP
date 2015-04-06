//
//  TestsFile.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 3/24/15.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

//import Foundation

//func test(){
//    //        LxFTPRequest * request = [LxFTPRequest uploadRequest];
//    //        request.serverURL = [NSURL URLWithString:FTP_SCHEME_HOST]URLByAppendingPathComponent:FILE_PATH];
//    //        request.localFileURL = [NSURL fileURLWithPath:LOCAL_FILE_SAVE_PATH];
//    //        request.username = USERNAME;
//    //        request.password = PASSWORD;
//    //        request.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent) {
//    //
//    //            NSLog(@"totalSize = %ld, finishedSize = %ld, finishedPercent = %f", totalSize, finishedSize, finishedPercent);
//    //        };
//    //        request.successAction = ^(Class resultClass, id result) {
//    //
//    //            NSLog(@"resultClass = %@, result = %@", resultClass, result);
//    //        };
//    //        request.failAction = ^(CFStreamErrorDomain domain, NSInteger error) {
//    //
//    //            NSLog(@"domain = %ld, error = %ld", domain, error);
//    //        };
//    //        [request start];
//    
//    let req = LxFTPRequest.uploadRequest()
//    req.serverURL = NSURL(string: "ftp://50.63.56.108:21/")?.URLByAppendingPathComponent("dev/testdir/0/test.png")
//    req.localFileURL = NSURL(fileURLWithPath: "/Users/ghans/Desktop/vim-cheatsheet.png")
//    req.username = "jayanthshetty"
//    req.password = "Thanks1@Give&"
//    
//    req.progressAction = {a,b,c in
//        println("total: \(a), doneSize: \(b), donePercent: \(c)")
//    }
//    
//    req.successAction = {a,b in
//        println(b)
//    }
//    
//    req.failAction = {a,b,c in
//        println(a)
//    }
//    
//    req.start()
//}
//
//
//func NMSSHTest() {
//    //        let session = NMSSHSession.connectToHost("192.210.208.114:22", withUsername: "root")
//    //
//    //        if session.connected {
//    //            session.authenticateByPassword("   ")
//    //
//    //            if session.authorized {
//    //                println("fuk yeaaaa! WE IN NIGGA")
//    //            }
//    //        }
//    //
//    //        let response = session.channel.execute("ls -l /var/www/", error: nil)
//    //        println("response: \(response)")
//    
//    //        NSString *file = @"/tmp/";
//    //        BOOL isDir = NO;
//    //        if([[NSFileManager defaultManager]
//    //            fileExistsAtPath:file isDirectory:&isDir] && isDir){
//    //                NSLog(@"Is directory");
//    //        }
//}
