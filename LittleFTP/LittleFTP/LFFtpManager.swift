//
//  LFFtpManager.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2/15/16.
//  Copyright © 2016 Gurinder Hans. All rights reserved.
//

import Foundation
//import FTPManager

//class LFFtpManager: NSObject, FTPManagerDelegate {
//    
//    private var ftpManager = FTPManager()
//    private var uploadCallback: ([NSObject: AnyObject] -> ())?
//    private var downloadCallback: ([NSObject: AnyObject] -> ())?
//    
//    override init() {
//        super.init()
//        self.ftpManager.delegate = self
//    }
//    
//    func ftpManagerDownloadProgressDidChange(processInfo: [NSObject : AnyObject]!) {
//        if let c = downloadCallback {
//            c(processInfo)
//        }
//    }
//    
//    func ftpManagerUploadProgressDidChange(processInfo: [NSObject : AnyObject]!) {
//        if let c = uploadCallback {
//            c(processInfo)
//        }
//    }
//    
//    func uploadFile(file: NSURL, withServer server: FMServer, finish: Bool -> (), progCb: ([NSObject: AnyObject] -> ())?) {
//        self.uploadCallback = progCb
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
//            let result = self.ftpManager.uploadFile(file, toServer: server)
//            finish(result)
//        })
//    }
//    
//    func downloadFile(filename: String, toFolder folder: NSURL, withServer server: FMServer, progCb: ([NSObject: AnyObject] -> ())?) {
//        self.downloadCallback = progCb
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
//            self.ftpManager.downloadFile(filename, toDirectory: folder, fromServer: server)
//        })
//    }
//    
//}