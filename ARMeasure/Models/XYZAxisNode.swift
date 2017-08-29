//
//  XYZAxisNode.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 16/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import Foundation
import SceneKit

/// 3D XYZ-axis model for debugging purpose
class XYZAxisNode {
    /**
                 ^
                 | y
                 |  /
                 | /
         ________|/________> x
                /|
               / |
            z /  |
     
     Frame and construction style.
     
     - axisLength: How long each x, y, z axis is
     
     */
    let axisLength:Float = 0.1
    
    let xAxisColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.7)
    let yAxisColor = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.7)
    let zAxisColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.7)
    
    var xAxisNode: SCNNode { return self._xAxisNode}
    var yAxisNode: SCNNode { return self._yAxisNode}
    var zAxisNode: SCNNode { return self._zAxisNode}

    private var _xAxisNode: SCNNode
    private var _yAxisNode: SCNNode
    private var _zAxisNode: SCNNode
    
    init(position origin: SCNVector3) {
        
        let xAxisVectorTo = SCNVector3(origin.x + axisLength, origin.y, origin.z)
        let yAxisVectorTo = SCNVector3(origin.x, origin.y + axisLength, origin.z)
        let zAxisVectorTo = SCNVector3(origin.x, origin.y, origin.z + axisLength)
        
        let xAxisVectorFrom = SCNVector3(origin.x - axisLength, origin.y, origin.z)
        let yAxisVectorFrom = SCNVector3(origin.x, origin.y - axisLength, origin.z)
        let zAxisVectorFrom = SCNVector3(origin.x, origin.y, origin.z - axisLength)
        
        _xAxisNode = MeasureVertex(
            from: xAxisVectorFrom, 
            to: xAxisVectorTo, 
            radius: Constants.measureLineRadius, 
            color: xAxisColor
        )
        
        _yAxisNode = MeasureVertex(
            from: yAxisVectorFrom, 
            to: yAxisVectorTo, 
            radius: Constants.measureLineRadius, 
            color: yAxisColor
        )
        
        _zAxisNode = MeasureVertex(
            from: zAxisVectorFrom, 
            to: zAxisVectorTo, 
            radius: Constants.measureLineRadius, 
            color: zAxisColor
        )
        
    }
}


