//
//  MeasureElement.swift
//  ARMeasure
//
//  Created by YOUNG on 28/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

class MeasureElement {
    let node: MeasureNode
    let isMeasurePlaneWithThisNode: Bool
    var vertexLengthLabel: MeasureVertexLengthLabel?
    var vertex: MeasureVertex?
    var xyzAxis: XYZAxisNode?
    
    init(measureNode node: MeasureNode,
         isMeasurePlaneWithThisNode: Bool,
         vertex: MeasureVertex? = nil ,
         vertexLengthLabel: MeasureVertexLengthLabel? = nil) {
        self.node = node
        self.isMeasurePlaneWithThisNode = isMeasurePlaneWithThisNode
        self.vertexLengthLabel = vertexLengthLabel
        self.vertex = vertex
    }
    
    deinit {
        node.removeFromParentNode()
        vertex?.removeFromParentNode()
        vertexLengthLabel?.distanceLabelNode.removeFromParentNode()
        xyzAxis?.xAxisNode.removeFromParentNode()
        xyzAxis?.yAxisNode.removeFromParentNode()
        xyzAxis?.zAxisNode.removeFromParentNode()
    }
}
