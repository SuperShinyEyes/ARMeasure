//
//  MeasureAreaPlane.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 17/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import SceneKit

class MeasureAreaPlane: SCNNode {

    override init() {
        super.init()
    }
    
    convenience init(positions: [SCNVector3]) {
        self.init()
        let geometrySource = SCNGeometrySource(vertices: positions)
        var indices: [Int] = Array(0..<positions.count)
        indices.append(0)
        let geometryElement = SCNGeometryElement(indices: indices, primitiveType: .polygon)
        self.geometry = SCNGeometry(sources: [geometrySource], elements: [geometryElement])
        self.geometry?.firstMaterial?.diffuse.contents = Constants.measurePlaneColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    

}
