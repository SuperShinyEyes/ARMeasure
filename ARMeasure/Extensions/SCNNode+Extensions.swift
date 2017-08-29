//
//  SCNNode+Extensions.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 10/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    // This part of the code is referred from
    // https://stackoverflow.com/a/42941966/3067013
    func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
        let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
        if length == 0 {
            return SCNVector3(0.0, 0.0, 0.0)
        }
        
        return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
        
    }
    
}
