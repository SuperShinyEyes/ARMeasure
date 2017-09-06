//
//  RealmManager.swift
//  ARMeasure
//
//  Created by YOUNG on 30/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import RealmSwift

/**
 The highest hierarchy in DB which contains all data
 */
final class MeasureSessionList: Object {
    @objc dynamic var id = ""
    let sessions = List<MeasureSession>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

/**
 Contains one whole session data.
 One session starts when user starts the app and ends when user exits
 the app
 */
final class MeasureSession: Object {
    @objc dynamic var id = ""
    let datum = List<MeasureData>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class MeasureData: Object {
    @objc dynamic var screenshotName = ""
    let worldCoordinates = List<Coordinates3D>()
    
    override static func primaryKey() -> String? {
        return "screenshotName"
    }
}

final class Coordinates3D: Object {
    @objc dynamic var x: Float = 0.0
    @objc dynamic var y: Float = 0.0
    @objc dynamic var z: Float = 0.0
}


class RealmManager {
    
    static let sharedInstance = RealmManager()
    
    var sessionList: MeasureSessionList? {
        return self.realm.objects(MeasureSessionList.self).first
    }
    
    var currentSession: MeasureSession? {
//        let predicate = NSPredicate(format: "#datum.@count > 0")
//        return sessionList?.sessions.filter(predicate).last
        return sessionList?.sessions.last
    }
    
    /// Current session MeasureData
    var currentDatum: List<MeasureData>? {
        return currentSession?.datum
    }
    
    private var sessionID: String
    private var notificationToken: NotificationToken!
    var realm: Realm!
    
    
    init() {
        sessionID = Date().iso8601
        setupRealm()
    }
    
    deinit {
        notificationToken.stop()
    }
    
    func setupRealm() {
        
        DispatchQueue.main.async {
            do {
                self.realm = try Realm()
                
                /// Create a session list DB if it doesn't exist.
                /// It is created only once.
                if self.realm.objects(MeasureSessionList.self).count == 0 {
                    try! self.realm.write {
                        let sessionList = MeasureSessionList()
                        sessionList.id = "database"
                        self.realm.add(sessionList)
                    }
                    
                }
                
//                /// Create new session at every app start
//                try! self.realm.write {
//                    guard let sessionList = self.realm.objects(MeasureSessionList.self).first else {
//                        return
//                    }
//
//                    let session = MeasureSession()
//                    session.id = Date().iso8601
//                    sessionList.sessions.insert(session, at: sessionList.sessions.count)
//                    self.realm.add(sessionList, update: true)
////                    self.realm.add(session)
//                }
                
                
                
//                func updateList() {
//                    if self.datum?.realm == nil, let list = self.realm.objects(MeasureSession.self).first {
//                        self.datum = list.datum
//                    } else {
//                        print("self.items.realm: \(self.datum?.realm)")
//                        print("self.realm.objects(TaskList.self).count: \(self.realm.objects(MeasureSession.self).count)")
//                        print("items not set")
//                    }
////                    self.tableView.reloadData()
//                }
//                updateList()
                
//                self.notificationToken = self.realm.addNotificationBlock{ _,_  in updateList()}
            } catch {
                print("Couldn't load Realm")
            }
        }
    }
    
    /**
     A Session created when a new measure is captured
     */
    private func createSesseion() {
        guard currentSession?.id != sessionID,
            let _ = self.realm else {
                Logger.log("Unncessary to create a new session", event: .info)
                return }
        
//        DispatchQueue.main.async {
            do {
                /// Create new session at every app start
                try self.realm.write {
                    guard let sessionList = self.realm.objects(MeasureSessionList.self).first else {
                        return
                    }
                    
                    let session = MeasureSession()
                    session.id = self.sessionID
                    sessionList.sessions.insert(session, at: sessionList.sessions.count)
                    self.realm.add(sessionList, update: true)
                    Logger.log("Created a new session", event: .info)
                }
            } catch {
                Logger.log("Couldn't create session", event: .error)
            }
        
//        }
    }
    
    func add(measure: Measure, screenshotName: String) {
        createSesseion()
        
        guard let datum: List<MeasureData> = self.currentDatum else {
            Logger.log("There's No datum i.e., NO SESSION!", event: .error)
            return
        }

        let measureData = MeasureData()
        
        try! datum.realm?.write {
            
            /// 1. Write measure node coordinates
            measure.measureNodesAsList.map {
                (node: MeasureNode) -> Coordinates3D in
                return Coordinates3D(value: [
                    "x":node.position.x,
                    "y":node.position.y,
                    "z":node.position.z]
                )
            }.forEach {
                (c: Coordinates3D) in
                /// Add in order
                measureData.worldCoordinates.insert(c, at: measureData.worldCoordinates.count)
            }
            
            /// 2. Write screenshot name
            Logger.log("measureData.screenshotName = \(screenshotName)", event: .verbose)
            measureData.screenshotName = screenshotName
            
            /// Add to the measure session data array
            datum.insert(measureData, at: datum.count)
            datum.realm?.add(datum, update: true)
        }
    }
}
