//
//  CustomLogFormatter.swift
//  WordCounter
//
//  Created by Jason Ho on 1/5/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

class CustomLogFormatter: NSObject, DDLogFormatter {
    func format(message logMessage: DDLogMessage!) -> String! {
        
        var prefixMessage = ""
        switch (logMessage.flag) {
        case DDLogFlag.verbose:
            prefixMessage = "其它"
            break
        case DDLogFlag.debug:
            prefixMessage = "記錄"
            break
        case DDLogFlag.info:
            prefixMessage = "提示"
            break
        case DDLogFlag.warning:
            prefixMessage = "警告"
            break
        case DDLogFlag.error:
            prefixMessage = "錯誤"
            break
        default:
            break
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timeString = formatter.string(from: Date())
        
        var fileInfo = ""
        let showImportantInfo = [DDLogFlag.warning, DDLogFlag.error]
        if(showImportantInfo.contains(logMessage.flag)){
            fileInfo = " (\(logMessage.fileName):\(logMessage.line))"
        }
        
        return "\(timeString) [\(prefixMessage)] > \(logMessage.message)\(fileInfo)"
    }
}
