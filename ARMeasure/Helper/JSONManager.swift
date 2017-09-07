//
//  JSONManager.swift
//  ARMeasure
//
//  Created by YOUNG on 06/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 JSONManager has two main responsibilities.
 1. JSON read & write wrapper
     - When user hits a share button, it creates the JSON file
 2. Manages a single "main" JSON file that contains the whole data of the entire
    images on disk. It is meant for the data export in iTunes file sharing.
 
 JSON format for the "main" JSON:
 {
     data: [
             {"screenShotName":"2017-09-06T11:38:09.011Z",
             "worldCoordinates":[[x,y,z]],
             "screenCoordinates":[[x,y]]},
             {"screenShotName":"2017-09-06T11:38:09.011Z",
             "worldCoordinates":[[x,y,z]],
             "screenCoordinates":[[x,y]]},
         ]
 }
 
 NOTE:
 I'm not sure how the single JSON file strategy is going to work in long term.
 Will it get corrupted? Do I need to rewrite it at every app start?
 */
class JSONManager {
    static let sharedInstance = JSONManager()
    let FILENAME = "data.json"
    
    var json: JSON? {
        return FileManagerWrapper.getJSONFromDisk(name: FILENAME)
    }
    
    private init() {
        setupJSON()
    }
    
    func setupJSON() {
        guard self.json == nil else { return }
        
        let json: JSON = [
            "data": []
        ]
        FileManagerWrapper.writeJSONToDisk(json: json, name: FILENAME)
    }
    
    func updateMainJSON(data: MeasureData) {
        guard let mainJSON = self.json else {
            Logger.log("Can't update main jSON. Couldn't load it.", event: .error)
            return }
        let json = convert(data: data)
        mainJSON["data"]
        
    }
    
    func append(left: JSON, right: JSON) -> JSON? {
        do {
            return try left.merged(with: right)
        } catch {
            Logger.log("Couldn't append JSON", event: .error)
        }
        return nil
    }
    /**
     Add data with a given screenshotName to JSON. The content of JSON
     is retrieved from Realm DB.
     */
    func convert(data: MeasureData) -> JSON {
//        DispatchQueue.main.async {
        
        /// 1. Convert data into JSON
        let worldCoordinates: [[Float]] = data.worldCoordinates.map { c in
            return [c.x,c.y,c.z]
        }
        Logger.log("worldCoordinates: \(worldCoordinates)", event: .verbose)
        
        let screenCoordinates: [[Float]] = data.screenCoordinates.map { c in
            return [c.x,c.y]
        }
        Logger.log("screenCoordinates: \(screenCoordinates)", event: .verbose)
        
        
        let json: JSON = [
            "screenShotName": data.screenshotName,
            "worldCoordinates": worldCoordinates,
            "screenCoordinates": screenCoordinates
        ]
        return json
        
//        }
    }
    
    
}
