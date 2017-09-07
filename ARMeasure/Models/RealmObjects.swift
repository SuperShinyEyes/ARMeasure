//
//  RealmObjects.swift
//  ARMeasure
//
//  Created by YOUNG on 07/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import RealmSwift
/**
 The highest hierarchy in DB which contains all data
 */
final public class MeasureSessionList: Object {
    @objc dynamic var id = ""
    let sessions = List<MeasureSession>()
    
    override static public func primaryKey() -> String? {
        return "id"
    }
}

/**
 Contains one whole session data.
 One session starts when user starts the app and ends when user exits
 the app
 */
final public class MeasureSession: Object {
    @objc dynamic var id = ""
    let datum = List<MeasureData>()
    
    override static public func primaryKey() -> String? {
        return "id"
    }
}

final public class MeasureData: Object {
    @objc dynamic var screenshotName = ""
    let worldCoordinates = List<Coordinates3D>()
    let screenCoordinates = List<Coordinates2D>()
    
    override static public func primaryKey() -> String? {
        return "screenshotName"
    }
}

final public class Coordinates3D: Object {
    @objc dynamic var x: Float = 0.0
    @objc dynamic var y: Float = 0.0
    @objc dynamic var z: Float = 0.0
}

final public class Coordinates2D: Object {
    @objc dynamic var x: Float = 0.0
    @objc dynamic var y: Float = 0.0
}
