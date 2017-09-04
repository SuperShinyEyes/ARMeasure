//
//  RealmManager.swift
//  ARMeasure
//
//  Created by YOUNG on 30/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import RealmSwift

final class MeasureDataList: Object {
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
    
    
    var datum = List<MeasureData>()
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    
    init() {
        setupRealm()
    }
    
    deinit {
        notificationToken.stop()
    }
    
    func setupRealm() {
        
        DispatchQueue.main.async {
            do {
                self.realm = try Realm()
                
                if self.realm.objects(MeasureDataList.self).count == 0 {
                    try! self.realm.write {
                        let list = MeasureDataList()
                        list.id = "database"
                        self.realm.add(list)
                    }
                    
                }
                
                func updateList() {
                    if self.datum.realm == nil, let list = self.realm.objects(MeasureDataList.self).first {
                        self.datum = list.datum
                    } else {
                        print("self.items.realm: \(self.datum.realm)")
                        print("self.realm.objects(TaskList.self).count: \(self.realm.objects(MeasureDataList.self).count)")
                        print("items not set")
                    }
//                    self.tableView.reloadData()
                }
                updateList()
                
                self.notificationToken = self.realm.addNotificationBlock{ _,_  in updateList()}
            } catch {
                print("Couldn't load Realm")
            }
        }
    }
    
    func add(measure: Measure, screenshotName: String) {
        let measureData = MeasureData()
        
        let datum = self.datum
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
            measureData.screenshotName = screenshotName
            
            /// Add to the measure session data array
            datum.insert(measureData, at: datum.count)
        }
    }
}
