//
//  RealmManager.swift
//  ARMeasure
//
//  Created by YOUNG on 30/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import RealmSwift
import SceneKit

protocol RealmManagerDelegate: class {
    func hideShowAlbumButton()
    func showShowAlbumButton()
    func updateShowAlbumButtonImage(with image: UIImage)
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
    
    var recentData: MeasureData? {
        return currentDatum?.last
    }
    
    private var sessionID: String
    private var notificationToken: NotificationToken!
    var realm: Realm!
    weak var delegate: RealmManagerDelegate?
    
    
    private init() {
        sessionID = Date().iso8601
        setupRealm()
    }
    
    deinit {
        notificationToken.stop()
    }
    
    private func getRealm() -> Realm {
        if let _ = NSClassFromString("XCTest") {
            return try!  Realm(configuration:
                Realm.Configuration(
                    fileURL: nil,
                    inMemoryIdentifier: "test",
                    encryptionKey: nil,
                    readOnly: false,
                    schemaVersion: 0,
                    migrationBlock: nil,
                    objectTypes: nil)
            )
        } else {
            return try! Realm()
        }
    }
    
    func setupRealm() {
        
//        DispatchQueue.main.async {
            do {
                self.realm = getRealm()
                Logger.log("Realm DB is loaded", event: .verbose)
                
                /// Create a session list DB if it doesn't exist.
                /// It is created only once.
                if self.realm.objects(MeasureSessionList.self).count == 0 {
                    do {
                        try self.realm.write {
                            let sessionList = MeasureSessionList()
                            sessionList.id = "database"
                            self.realm.add(sessionList)
                        }
                    } catch {
                        Logger.log("Couldn't write to Realm for setup", event: .severe)
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
                Logger.log("Couldn't load Realm", event: .severe)
            }
//        }
    }
    
    /**
     A Session created when a new measure is captured
     */
    private func createSesseion() {
        guard currentSession?.id != sessionID,
            let _ = self.realm else { return }
        
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
    
    /**
     RealmManager.add() is the core of data saving logic in ARMeasure.
     add() does:
         1. write data to Realm DB,
         2. update main json
         3. write screenshots(withGraphic/withoutGraphic) to disk
         4. update album image
     */
    func add(measure: Measure, screenshotName: String) -> MeasureData? {
        createSesseion()
        
        /// Prepare content for Realm DB write
        guard let datum: List<MeasureData> = self.currentDatum else {
            Logger.log("There's No datum i.e., NO SESSION!", event: .error)
            return nil
        }
        
        /// SceneView is needed for coordinate translation(projectPoint())
        guard let sceneView = measure.delegate?.sceneView else {
            Logger.log("There's SceneView: Cannot add to Realm!", event: .error)
            return nil
        }

        let measureData = MeasureData()
        
        let screenCoordinates: [SCNVector3] = measure.measureNodesAsList.map {
            return sceneView.projectPoint($0.position)
        }
        
        /// Write to Realm
        do {
            try datum.realm?.write {
                
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
                
                /// 3. Write screen coordinates
                screenCoordinates.map {
                    (v: SCNVector3) -> Coordinates2D in
                    return Coordinates2D(value: [
                        "x":v.x,
                        "y":v.y
                        ]
                    )
                    }.forEach {
                        (c: Coordinates2D) in
                        /// Add in order
                        measureData.screenCoordinates.insert(c, at: measureData.screenCoordinates.count)
                }
                
                /// Add to the measure session data array
                datum.insert(measureData, at: datum.count)
                datum.realm?.add(datum, update: true)
            }
        } catch {
            Logger.log("MeasureData Addition Failed", event: .severe)
            return nil
        }
        
//        DispatchQueue.main.async {
        
//        }
        
        
        return measureData
    }
}
