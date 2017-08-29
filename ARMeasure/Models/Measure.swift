//
//  Marker.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 09/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import Foundation
import ARKit

protocol MeasureDelegate: class {
    var sceneView: ARSCNView! { get set }
    
    func enableAreaCalculation()
    
    func disableAreaCalculation()
    
    var isAreaCalculationAvailable: Bool { get }
    
    func updateLabel(perimeter: Float, area: Float)
}



/// Singleton Measure model
class Measure {
    
    static let sharedInstance = Measure()
//    private var measureNodesAsList: [SCNNode]
    private var measureElementsAsList = [MeasureElement]()
    private var measureNodesAsList: [SCNNode] {
        return measureElementsAsList.map { $0.node }
    }
    private var _isClosed = false
    private var _is2D = true {
        didSet {
            if !_is2D {
                self.delegate?.disableAreaCalculation()
            }
        }
    }
    weak var delegate: MeasureDelegate?
    
    
    private init() {
    }
    
    func reset() {
        measureElementsAsList = [MeasureElement]()
        delegate?.sceneView.scene.rootNode.childNodes.forEach{
            child in
            child.removeFromParentNode()
        }
        _is2D = true
        _isClosed = false
        
    }
    
    /**
     Refer to deinit() destructor of MeasureElement
     */
    func undo() {
        guard let _ = measureElementsAsList.popLast() else {
            return
        }
        
        /// Activate "Get Area" Button if necessary
        if let element = measureElementsAsList.last {
            if delegate!.isAreaCalculationAvailable && element.isMeasurePlaneWithThisNode {
               delegate!.enableAreaCalculation()
            }
        }
    }
    
    func getArea() {
        let measureNodesAsList = measureElementsAsList.map { $0.node }
        guard let to = measureNodesAsList.first,
            let from = measureNodesAsList.last,
            let area = self.area,
            let center = self.center else {
            return
        }
        print("area: \(area)")
        measureNodesAsList.forEach { node in
            print(node.position)
        }
        _isClosed = true
        delegate?.updateLabel(perimeter: perimeter!, area: area)
        addMeasureVertex(start: from.position, end: to.position)
        addMeasureAreaLabel(area: area, position: center)
    }
    
    
}




/// Adding node, vertex, text label
extension Measure {
    /**
     Measure node addtion logic
     1. Check if the existing nodes make a plane. i.e., are they flat?
     - If yes, check if the plane will still be a plane with
     the new node
     1) If yes,
     * Activate "Get area" Button if not active
     * Cancel noise if necessary ( This is crucial for area
     calculation )
     2) If not,
     * Deactivate "Get area" Button
     2. Add the new node
     */
    func addMeasureNode(newVector position: SCNVector3, targetLookAt: SCNNode? = nil) {
        guard let delegate = self.delegate else {
            return
            
        }
        var positionTemp = position
        let lastIndex = measureElementsAsList.count
        
        if _is2D {
            if isPlaneStillPlaneWithNewNode(nodeNew: positionTemp) {
                if lastIndex == 2 {
                    delegate.enableAreaCalculation()
                }
                if lastIndex > 0 && Settings.cancelNoise {
                    positionTemp = cancelNoise(position: position)
                }
            } else {
                _is2D = false
            }
        }
        let measureNode = MeasureNode(position: positionTemp)
        let measureElement = MeasureElement(
            measureNode: measureNode,
            isMeasurePlaneWithThisNode: _is2D
        )
        
        delegate.sceneView.scene.rootNode.addChildNode(measureNode)
        measureElementsAsList.append(measureElement)
        
        
        
        /// Add a vertex to the new node
        if measureElementsAsList.count > 1 {
            let nodeStart = measureElementsAsList[measureElementsAsList.count - 2].node
            let nodeEnd = measureElementsAsList[measureElementsAsList.count - 1].node
            addMeasureVertex(start: nodeStart.position, end: nodeEnd.position)
        }
        
        if Settings.isDebugging {
            addXYZAxisNode(scene: delegate.sceneView.scene, position: measureNode.position)
        }
    }
    
    
    private func addMeasureVertex(start: SCNVector3, end: SCNVector3) {
        let vertex = MeasureVertex(from: start,
                                   to: end,
                                   radius: Constants.measureLineRadius,
                                   color: Constants.measureLineColor)
        delegate?.sceneView.scene.rootNode.addChildNode(vertex)
        
        measureElementsAsList.last?.vertex = vertex
        
        addMeasureVertexLengthLabel(start: start, end: end)
        
        delegate?.updateLabel(perimeter: perimeter!, area: 0.0)
    }
    
    /**
     Add text label at the middle of the vertex.
     
     Visual description:
     97.2cm                     2.09m                 40.12cm
     O===================O===============================O===========O
     */
    private func addMeasureVertexLengthLabel(start: SCNVector3, end: SCNVector3){
        let vertexLengthLabel = MeasureVertexLengthLabel(vectorStart: start, vectorEnd: end, id: 1, targetLookAt: delegate!.sceneView.pointOfView!)
        delegate!.sceneView.scene.rootNode.addChildNode(vertexLengthLabel.distanceLabelNode)
        
        measureElementsAsList.last?.vertexLengthLabel = vertexLengthLabel
    }
    
    private func addMeasureAreaLabel(area: Float, position: SCNVector3) {
        let label = MeasureAreaLabel(area: area, position: position, targetLookAt: delegate!.sceneView.pointOfView!)
        delegate?.sceneView.scene.rootNode.addChildNode(label.node)
    }
}




/// Geometry Calculations
extension Measure {
    func isPlaneStillPlaneWithNewNode(nodeNew: SCNVector3) -> Bool {
        guard let normal = normalVectorOfPlane else {
            return true
        }
        let count = measureElementsAsList.count
        let normalNew = getNormalVectorOfThreePoints(
            n1: measureElementsAsList[count-2].node.position,
            n2: measureElementsAsList[count-1].node.position,
            n3: nodeNew)
        print("normal: \(normal)")
        print("normalnew: \(normalNew)")
        return normal.isParallelTo(to: normalNew)
    }
    
    func getNormalVectorOfThreePoints(n1: SCNVector3, n2: SCNVector3, n3: SCNVector3) -> SCNVector3 {
        let v1 = n2 - n1
        let v2 = n3 - n2
        return v1.cross(v2)
    }
    
    func getEquationOfPlane(n1: SCNVector3, n2: SCNVector3, n3: SCNVector3) -> SCNVector4 {
        let n = getNormalVectorOfThreePoints(n1: n1, n2: n2, n3: n3)
        let d = n1.x * n.x + n1.y * n.y + n1.z * n.z
        return SCNVector4(n.x, n.y, n.z, d)
    }
    
    var normalVectorOfPlane: SCNVector3? {
        guard measureElementsAsList.count >= 3 else { return nil }
        let n1 = measureElementsAsList[0].node.position
        let n2 = measureElementsAsList[1].node.position
        let n3 = measureElementsAsList[2].node.position
        return getNormalVectorOfThreePoints(n1: n1, n2: n2, n3: n3)
    }
    
    
    /**
     Area of polygon in any orientation in 3D
     Reference(math): http://geomalgorithms.com/a01-_area.html#3D%20Polygons
     Reference(code): https://stackoverflow.com/a/12643315/3067013
     */
    var area: Float? {
        guard measureNodesAsList.count > 2 && _is2D else {
            return nil
        }
        
        let segments: [(SCNVector3, SCNVector3)] = (0..<measureNodesAsList.count).map{
            (i: Int) -> (SCNVector3, SCNVector3) in
            if i < measureNodesAsList.count - 1 {
                return (measureNodesAsList[i].position, measureNodesAsList[i+1].position)
            } else {
                return (measureNodesAsList[i].position, measureNodesAsList[0].position)
            }
        }
        
        let segmentsCrossProduct: [SCNVector3] = segments.map{ $0.0.cross($0.1) }
        print("crossed: \(segmentsCrossProduct)")
        let segmentsCrossProductSum = segmentsCrossProduct.reduce(SCNVector3.zero) {
            (v1: SCNVector3, v2: SCNVector3) -> SCNVector3 in
            SCNVector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
        }
        print("total of plane: \(segmentsCrossProductSum)")
        let planeUnitNormalVector = normalVectorOfPlane!.normalized()
        print("normal_unit of plane: \(planeUnitNormalVector)")
        
        return abs(segmentsCrossProductSum.dot(planeUnitNormalVector) / 2)
        
    }
    
    var center: SCNVector3? {
        guard measureNodesAsList.count > 0 else { return nil }
        let count = Float(measureNodesAsList.count)
        let x = measureNodesAsList.map{ node in node.position.x }.reduce(0.0, +) / count
        let y = measureNodesAsList.map{ node in node.position.y }.reduce(0.0, +) / count
        let z = measureNodesAsList.map{ node in node.position.z }.reduce(0.0, +) / count
        return SCNVector3(x, y, z)
    }
    
    var perimeter: Float? {
        guard measureNodesAsList.count > 1 else { return nil }
        
        var perimeter:Float = (0..<measureNodesAsList.count-1).map{
            i in
            
            let n0 = measureNodesAsList[i]
            let n1 = measureNodesAsList[i+1]
            return n0.position.distance(from: n1.position)
            }.reduce(0.0, +)
        if !_isClosed {
            return perimeter
        } else {
            let n0 = measureNodesAsList.first!
            let n1 = measureNodesAsList.last!
            perimeter += n0.position.distance(from: n1.position)
            return perimeter
        }
    }
}




/// Noise cancelation for new node
extension Measure {
    
    
    func cancelNoise(WithPlane equationOfPlane: SCNVector4, vector v: SCNVector3) -> SCNVector3 {
        let a = equationOfPlane.x
        let b = equationOfPlane.y
        let c = equationOfPlane.z
        let d = equationOfPlane.w
        
        /// Check if any element of normal vector is zero.
        /// Watch out the zero division
        var candidates = [SCNVector3]()
        if !a.isZero {
            let xNew: Float = ( d - ( c * v.z + b * v.y ) ) / a
            candidates.append(SCNVector3(xNew, v.y, v.z))
        }
        if !b.isZero {
            let yNew: Float = ( d - ( a * v.x + c * v.z ) ) / b
            candidates.append(SCNVector3(v.x, yNew, v.z))
        }
        if !c.isZero {
            let zNew: Float = ( d - ( a * v.x + b * v.y ) ) / c
            candidates.append(SCNVector3(v.x, v.y, zNew))
        }
        return zip(candidates, candidates.map{ $0.distance(from: v) }).sorted{ $0.1 < $1.1}[0].0
        
    }
    
    
    /**
     Cancel noise
     1. Horizontal plane is special because it is most common so we want
     it to be horizontally flat i.e., y is constant
     2. Other than horizontal plane, cancel noise according to the plane
     */
    func cancelNoise(position v: SCNVector3) -> SCNVector3 {
        guard let lastNode = measureNodesAsList.last else { return v }
        let direction: SCNVector3 = v - lastNode.position
        if direction.isNearNorizontal() {
            if measureNodesAsList.count < 3 {
                return SCNVector3(v.x, lastNode.position.y, v.z)
            } else {
                let equationOfPlane = getEquationOfPlane(
                    n1: measureNodesAsList[0].position,
                    n2: measureNodesAsList[1].position,
                    n3: measureNodesAsList[2].position
                )
                return cancelNoise(WithPlane: equationOfPlane, vector: v)
            }
        } else {
            return v
        }
    }
}




/// Computed properties
extension Measure {
    var startNode: SCNNode? {
        get {
            return measureNodesAsList.first
        }
    }
    
}




/// Debug purpose elements
extension Measure {
    private func addXYZAxisNode(scene: SCNScene, position: SCNVector3) {
        let axis = XYZAxisNode(position: position)
        measureElementsAsList.last?.xyzAxis = axis
        scene.rootNode.addChildNode(axis.xAxisNode)
        scene.rootNode.addChildNode(axis.yAxisNode)
        scene.rootNode.addChildNode(axis.zAxisNode)
    }
}
