//
//  AppConstants.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2015-05-26.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

// progress types
struct ProgressType {
    static let UPLOAD = "progTypeUpload"
    static let DOWNLOAD = "progTypeDownload"
}

// app observers used for various purposes
struct Observers {
    static let FILE_BROWSER_OVERLAY_PANEL = "setOverlay"
    static let CURRENT_SERVER_CHANGED = "serverChanged"
    static let NEW_CONNECTION_PATH = "newConnectionPath"
}

// server keys
struct Server {
    static let URL          = "serverURL"
    static let PORT         = "serverPort"
    static let UNAME        = "userName"
    static let PASS         = "userPass"
    static let STATE        = "serverState"
    static let TYPE         = "serverType"
    static let ABS_PATH     = "serverAbsolutePath"
}


// all server types
struct ServerType {
    static let FTP      = "FTP"
    static let SFTP     = "SFTP"
}
