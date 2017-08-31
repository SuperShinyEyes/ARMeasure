//
//  FileManager.swift
//  ARMeasure
//
//  Created by YOUNG on 31/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit

enum ImageFormat: String {
    case png = ".png"
    case jpeg = ".jpg"
}

enum JPEGQuality: CGFloat {
    case fine = 1.0
    case good = 0.8
    case normal = 0.6
    case low = 0.4
    case poor = 0.2
}

struct FileManagerWrapper {
    
    static func getPathWithFileName(FileName name: String) -> URL? {
        guard let path = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return nil }
        
        return path.appendingPathComponent(name)
    }
    static func writeImageToDisk(image: UIImage, imageName: String, format: ImageFormat, jpegQuality: JPEGQuality = .good) {
        guard let url = getPathWithFileName(FileName: imageName + format.rawValue) else {
            return
        }
        
        print("Write image @ \(url)")
        
        switch format {
            case .png:
                if let data = UIImagePNGRepresentation(image) {
                    try? data.write(to: url, options: .atomic)
            }
            case .jpeg:
                if let data = UIImageJPEGRepresentation(image, jpegQuality.rawValue) {
                    try? data.write(to: url, options: .atomic)
            }
            
        }
    }


}


extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
