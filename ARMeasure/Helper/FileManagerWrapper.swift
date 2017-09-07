//
//  FileManager.swift
//  ARMeasure
//
//  Created by YOUNG on 31/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

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
    
    static func getPathWithFileName(FileName name: String, format: String = "") -> URL? {
        guard let path = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first
            else {
                Logger.log("Couldn't get path for \(name + format)", event: .warning)
                return nil }
        
        return path.appendingPathComponent(name + format)
    }
    
    
    static func writeImageToDisk(image: UIImage, imageName: String, format: ImageFormat, jpegQuality: JPEGQuality = .good) {
        guard let url = getPathWithFileName(FileName: imageName + format.rawValue) else {
            print("@writeImageToDisk: url doesn't exist")
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
    
    /**
     TODO:
     Fix file existence check
     FileManager.default.fileExists(atPath: path) always returns false
     even though a file exists at a path.
     
     Tests:
     print("FileManager.default.fileExists(atPath: path.path) = \(FileManager.default.fileExists(atPath: path))")
     print("FileManager.default.fileExists(atPath: name) = \(FileManager.default.fileExists(atPath: name))")
     print(getPathWithFileName(FileName: name)?.path)
     print(getPathWithFileName(FileName: name)?.absoluteString)
     print("FileManager.default.fileExists(atPath: absolute) = \(FileManager.default.fileExists(atPath: (getPathWithFileName(FileName: name)?.absoluteString)!))")
     print(getPathWithFileName(FileName: name)?.relativeString)
     print("FileManager.default.fileExists(atPath: relative) = \(FileManager.default.fileExists(atPath: (getPathWithFileName(FileName: name)?.relativeString)!))")
     */
    static func getImageFromDisk(name: String) -> UIImage? {
        /// https://stackoverflow.com/questions/24181699/how-to-check-if-a-file-exists-in-the-documents-directory-in-swift
        guard let path: String = getPathWithFileName(FileName: name)?.path,
            let image = UIImage(named: path) else {
                Logger.log("FileNotFoundError! '\(name)'", event: .error)
                return nil
                
        }
        return image
    }
    
    static func getJSONFromDisk(name: String) -> JSON? {
        guard let path: String = getPathWithFileName(FileName: name)?.path else {
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            let json = JSON(data: data)
            if json != JSON.null {
                return json
            } else {
                Logger.log("Could not get json from file, make sure that file contains valid json.", event: .error)
            }
        } catch let error {
            Logger.log(error.localizedDescription, event: .error)
        }
        return nil
    }
    
    static func writeJSONToDisk(json: JSON, name: String) {
        guard let saveFileURL = FileManagerWrapper.getPathWithFileName(FileName: name)
            else { return }
        
        let jsonData = try! json.rawData()
        try! jsonData.write(to: saveFileURL, options: .atomic)
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
