//
//  Logger.swift
//  ARMeasure
//
//  Created by YOUNG on 05/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

enum LogEvent: String {
    case error = "[‼️]"
    case info = "[ℹ️]"
    case debug = "[💬]"
    case verbose = "[🔬]"
    case warning = "[⚠️]"
    case severe = "[🔥]"
}

struct Logger {
    
    static private var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static fileprivate var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    static private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }

    static func log(message: String,
                    event: LogEvent,
                    fileName: String = #file,
                    line:Int = #line,
                    funcName: String = #function) {
        #if DEBUG
        print("\(Date().toString()) \(event.rawValue)[\(sourceFileName(filePath: fileName))]:\(line) \(funcName) -> \(message)")
        #endif
    }
}

extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}
