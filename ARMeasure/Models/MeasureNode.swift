//
//  Marker.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 16/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import SceneKit

/// Nodes which connects vertices of measures.
class MeasureNode: SCNNode {
    
    override init() {
        super.init()
    }
    
    convenience init(position: SCNVector3) {
        self.init()
        
        self.geometry = SCNSphere(radius: Constants.markerRadius)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
}

