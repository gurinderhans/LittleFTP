//
//  LFFTPController.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/14/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
//import FTPManager

//class LFFTPController: NSObject {
//    
//    lazy var ftpManager = {
//        return FTPManager()
//    }()
//    
//    func listServerFolder(name:String, files:[LFFile]? -> Void) {
//        if let s:LFServer = LFServerManager.activeServer {
//            let destination = LFServerManager.activeServer?.activeUrl.URLByAppendingPathComponent(name, isDirectory: true).standardizedURL?.absoluteString
//            let fms = FMServer(destination: destination, username: s.userName, password: s.password)
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
//                let resp = self.ftpManager.contentsOfServer(fms)
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    if resp != nil {
//                        LFServerManager.activeServer?.activeUrl = NSURL(string: destination!)
//                        var fls = [LFFile]()
//                        for i in resp {
//                            let fl = LFFile(name: i["kCFFTPResourceName"] as! String, modDate: i["kCFFTPResourceModDate"] as! NSDate, type: i["kCFFTPResourceType"] as! NSInteger)
//                            fls.append(fl)
//                        }
//                        files(fls)
//                    } else {
//                        files(nil)
//                    }
//                })
//            })
//        }
//    }
//    
//    func uploadFile(file: NSURL, finish: Bool -> (), progCb: ([NSObject: AnyObject] -> ())?) {
//        if let s:LFServer = LFServerManager.activeServer {
//            let destination = LFServerManager.activeServer?.activeUrl.standardizedURL?.absoluteString
//            let fms = FMServer(destination: destination, username: s.userName, password: s.password)
//            
//            LFFtpManager().uploadFile(file, withServer: fms, finish: { (success) -> () in
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    finish(success)
//                })
//            }, progCb: { (info) -> () in
//                if let c = progCb {
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        c(info)
//                    })
//                }
//            })
//        }
//    }
//}
