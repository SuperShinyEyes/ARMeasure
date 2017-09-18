//
//  DistanceLabel.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 10/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class Label {
    let distance: Float
    let vectorStart: SCNVector3
    let vectorEnd: SCNVector3
    let direction: SCNVector3
    var textureForDistanceLabelNode: SKLabelNode!
    var distanceLabelNode: SCNNode!
    
    let position: SCNVector3
    
    init(vectorStart:SCNVector3, vectorEnd:SCNVector3, id: Int) {
        self.vectorStart = vectorStart
        self.vectorEnd = vectorEnd
        self.distance = vectorStart.distance(from: vectorEnd)
        direction = vectorEnd - vectorStart
        position = SCNVector3.getMiddle(start: vectorStart, end: vectorEnd)
        
    }
    
    func rotateLabelBasic() {
        let initialAngle = SCNMatrix4MakeRotation(Constants.pi, 1, 0, 0)
        distanceLabelNode.transform = SCNMatrix4Mult(initialAngle, distanceLabelNode.transform)
    }
    
    func rotateLabelAlongTheLine() {
        // Initially the label is
        let initialAngle = SCNMatrix4MakeRotation(Constants.pi, 1, 0, 0)
        
        let yAngle = SCNMatrix4MakeRotation(direction.yRotation, 0, 1, 0)
        let zRotation = direction.zRotation
        let zAngle = SCNMatrix4MakeRotation(zRotation, 0, 0, 1)
        print("zRotation: \(zRotation*180/Constants.pi)")
        let rotationMatrix = SCNMatrix4Mult(SCNMatrix4Mult(initialAngle, zAngle), yAngle)
        distanceLabelNode.transform = SCNMatrix4Mult(rotationMatrix, distanceLabelNode.transform)
        //        distanceLabelNode.rotation = SCNVector4(1, 0, 0, Constants.pi)
        //        distanceLabelNode.rotation = SCNVector4(0, 1, 0, direction.yRotation)
    }
    
}


class MeasureVertexLengthLabel: Label {
    
//    override init(vectorStart: SCNVector3, vectorEnd: SCNVector3, id: Int) {
//        super.init(vectorStart: vectorStart, vectorEnd: vectorEnd, id: id)
//    }
    
    init(vectorStart: SCNVector3, vectorEnd: SCNVector3, id: Int, targetLookAt: SCNNode? = nil) {
        super.init(vectorStart: vectorStart, vectorEnd: vectorEnd, id: id)
        createLabel(id: id, position: position)
        if let target = targetLookAt {
            setLookAtConstraint(target: target)
        } else {
            rotateLabelAlongTheLine()
        }
        distanceLabelNode.position = position
        distanceLabelNode.position.y += 0.01
        
    }
    
    /**
     Rotate a material around Z-axis 180° before being added to
     SCNGeometry object.
     
     Used when creating a text 3D SCNNode from 2D SKLabelNode because
     it is initially in wrong rotation.
     
     - parameter material: SCNMaterial containing a diffuse content
     */
    private func rotateMaterialAroundZAxis(material: SCNMaterial) {
        material.diffuse.contentsTransform = SCNMatrix4MakeRotation(Constants.pi, 0, 0, 1)
        material.diffuse.wrapT = SCNWrapMode.repeat
        material.diffuse.wrapS = SCNWrapMode.repeat
    }
    
    private func createLabel(id: Int, position:SCNVector3) {
        let width: CGFloat = 500
        let height = width / 2
        let skScene = SKScene(size: CGSize(width: width, height: height))
//        skScene.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        textureForDistanceLabelNode = SKLabelNode(fontNamed: "Menlo-Bold")
        textureForDistanceLabelNode.fontSize = CGFloat(min(20 * self.distance + 25, 150))
//        Logger.log("Font size: \(textureForDistanceLabelNode.fontSize)", event: .debug)
//        if self.distance < 0.5 {
//            textureForDistanceLabelNode.fontSize = Constants.measureLabelFontSizeSmall
//        } else {
//            textureForDistanceLabelNode.fontSize = Constants.measureLabelFontSizeLarge
//        }
        
        textureForDistanceLabelNode.position.y = height / 2
        textureForDistanceLabelNode.position.x = width / 2
        textureForDistanceLabelNode.text = self.distance.__reprLength__
        
        skScene.addChild(textureForDistanceLabelNode)
        
        let planeWidth: CGFloat = 0.5
        let plane = SCNPlane(width:  planeWidth, height: planeWidth / 5)
        
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = true
        material.diffuse.contents = skScene

        rotateMaterialAroundZAxis(material: material)

        plane.materials = [material]
        
        distanceLabelNode = SCNNode(geometry: plane)
        distanceLabelNode.name = String(id)

    }
    
    /**
     Lock the rotation of node towards the target(camera)
     
     For better visibility of the label for users
     
     - parameter target: SCNView.scene.PointOfView (camera)
     */
    private func setLookAtConstraint(target: SCNNode) {
        let constraint = SCNLookAtConstraint(target: target)
        constraint.isGimbalLockEnabled = true
        self.distanceLabelNode.constraints = [constraint]
    }
    
}

class MeasureAreaLabel {
    var node: SCNNode!
    let area: Float
    
    init(area: Float, position: SCNVector3, targetLookAt: SCNNode? = nil) {
        self.area = area
        createLabel(id: "area", position: position)
        if let target = targetLookAt {
            setLookAtConstraint(target: target)
        } else {
            rotate()
        }
        
    }
    
    private func createLabel(id: String, position:SCNVector3) {
        let width: CGFloat = 500
        let height = width / 3
        let skScene = SKScene(size: CGSize(width: width, height: height))
        //        skScene.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        
        let textureForDistanceLabelNode = SKLabelNode(fontNamed: "Menlo-Bold")
        textureForDistanceLabelNode.fontColor = UIColor(red: 252/255, green: 106/255, blue: 250/255, alpha: 1.0) 
        if self.area < 0.01 {
            textureForDistanceLabelNode.fontSize = Constants.measureLabelFontSizeSmall
        } else if self.area < 0.1 {
            textureForDistanceLabelNode.fontSize = Constants.measureLabelFontSizeLarge
        } else {
            textureForDistanceLabelNode.fontSize = Constants.measureLabelFontSizeXLarge
        }
        
        textureForDistanceLabelNode.position.y = height / 2
        textureForDistanceLabelNode.position.x = width / 2
        textureForDistanceLabelNode.text = self.area.__reprArea__
        skScene.addChild(textureForDistanceLabelNode)
        
        let planeWidth: CGFloat = 0.5
        let plane = SCNPlane(width:  planeWidth, height: planeWidth / 5)
        
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        rotateMaterialAroundZAxis(material: material)
        plane.materials = [material]
        
        node = SCNNode(geometry: plane)
        node.name = String(id)
        node.position = position
        
    }
    
    
    /**
     Rotate a material around Z-axis 180° before being added to
     SCNGeometry object.
     
     Used when creating a text 3D SCNNode from 2D SKLabelNode because
     it is initially in wrong rotation.
     
     - parameter material: SCNMaterial containing a diffuse content
     */
    private func rotateMaterialAroundZAxis(material: SCNMaterial) {
        material.diffuse.contentsTransform = SCNMatrix4MakeRotation(Constants.pi, 0, 0, 1)
        material.diffuse.wrapT = SCNWrapMode.repeat
        material.diffuse.wrapS = SCNWrapMode.repeat
    }
    
    func rotate() {
        let initialAngle = SCNMatrix4MakeRotation(Constants.pi, 1, 0, 0)
        node.transform = SCNMatrix4Mult(initialAngle, node.transform)
    }
    
    private func setLookAtConstraint(target: SCNNode) {
        let constraint = SCNLookAtConstraint(target: target)
        constraint.isGimbalLockEnabled = true
        self.node.constraints = [constraint]
    }
}

extension Float {
    var __reprArea__: String {
        if self > 0.01 {
            return "\(Float(Int(self*100)) / 100)m^2"
        } else {
            return"\(Float(Int(self*1000000)) / 100)cm^2"
        }
    }
    
    var __reprLength__: String {
        if self > 1 {
            return "\(Float(Int(self*100)) / 100)m"
        } else {
            return"\(Float(Int(self*10000)) / 100)cm"
        }
    }
}
