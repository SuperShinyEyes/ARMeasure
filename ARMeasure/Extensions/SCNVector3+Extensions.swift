//
//  SCNVector3+Extensions.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 10/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import Foundation
import ARKit

extension SCNVector3 {
    func distance(from: SCNVector3) -> Float {
        let distanceX = self.x - from.x
        let distanceY = self.y - from.y
        let distanceZ = self.z - from.z
//        print("@Distance:")
//        print("x: \(distanceX)")
//        print("y: \(distanceY)")
//        print("z: \(distanceZ)")
//        print("distance = \(sqrtf( powf(distanceX, 2) + powf(distanceY, 2) + powf(distanceZ, 2) ))")
        return sqrtf( powf(distanceX, 2) + powf(distanceY, 2) + powf(distanceZ, 2) )
    }
    
}

extension SCNVector3 {
    
    /**
     Check the parallelism between two vectors.
     Two vectors are parallel if the angle between them is
         1) pi, or
         2) 0
     This logic is derived from dot product:
     v * w = v.len * w.len * cos(angle)
     */
    func isParallelTo(to: SCNVector3) -> Bool {
        let result = self.dot(to) - self.length() * to.length()
        print("isParallelTo: result: \(result)")
        return abs(self.dot(to) - self.length() * to.length()) < Constants.epsilon
    }
    
    func isNearNorizontal() -> Bool {
        let directionZRotationInDegree = abs(self.zRotation) * 180 / Constants.pi
        return directionZRotationInDegree < 10
    }
//    var normalized: SCNVector3 {
//        let length = sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
//        if length == 0 {
//            return SCNVector3(0.0, 0.0, 0.0)
//        }
//        
//        return SCNVector3( self.x / length, self.y / length, self.z / length)
//        
//    }
}

/// Extensions for rotation matrix
extension SCNVector3 {
    
    var xRotation: Float {
        let radian = SCNVector3.getRadianForA(sideA: self.y, sideB: self.z)
        if self.y >= 0 && self.z >= 0 {
            return -radian
        }
        else if self.y >= 0 && self.z < 0 {
            return Constants.pi - radian
        } else if self.y < 0 && self.z >= 0 {
            return radian
        } else {
            return -(Constants.pi - radian)
        }
        
    }
    
    /// Rotation around y-axis in radian
    var yRotation: Float {
        let radian = SCNVector3.getRadianForA(sideA: self.z, sideB: self.x)
        if self.z < 0 && self.x >= 0 {
            return radian
        } else if self.z < 0 && self.x < 0 {
            return -(Constants.pi - radian)
        } else if self.z > 0 && self.x < 0 {
            return Constants.pi - radian
        } else {
            return -radian
        }
    }
    
    
    /// Rotation around z-axis in radian
    var zRotation: Float {
        let a = abs(self.y)
        let b = sqrtf(powf(self.x, 2) + powf(self.z, 2))
        let radian = SCNVector3.getRadianForA(sideA: a, sideB: b)

        if self.x >= 0 && self.y >= 0 {
            /// + +
            print("case 1")
            return radian
        } else if self.x < 0 && self.y >= 0 {
            /// - +
            print("case 2")
            return -radian
        } else if self.x < 0 && self.y < 0 {
            /// - -
            print("case 3")
            return radian
        } else {
            /// + -
            print("case 4")
            return -radian
        }
    }
    
    /**
     Gets a radian of an angle 'a' which is the opposite of side A
     
     - Parameter:
     - sideA: A triangle side
     - sideB: A triangle side
     
     - Returns: Degree in radian
     */
    static func getRadianForA(sideA a: Float, sideB b: Float) -> Float {
        
        let c = sqrtf(powf(a, 2) + powf(b, 2))
        let cosA = b / c
        let radian = acos(cosA)
        return radian
    }
    
}



extension SCNVector3 {
    
    static func getMiddle(start: SCNVector3, end: SCNVector3) -> SCNVector3 {
        let c = ( end - start ) / 2
        return start + c
    }
    
    static let zero = SCNVector3(0,0,0)
    
    static func ==(v1: SCNVector3, v2: SCNVector3) -> Bool {
        return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z
    }
    
//    static func /(v: SCNVector3, c: Float) -> SCNVector3 {
//        let x = v.x / c
//        let y = v.y / c
//        let z = v.z / c
//        return SCNVector3(x, y, z)
//    }
//
//    static func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
//        let x = lhs.x - rhs.x
//        let y = lhs.y - rhs.y
//        let z = lhs.z - rhs.z
//        return SCNVector3(x, y, z)
//    }
//
//    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
//        let x = lhs.x + rhs.x
//        let y = lhs.y + rhs.y
//        let z = lhs.z + rhs.z
//        return SCNVector3(x, y, z)
//    }

}

/// Debugging purpose extensions
extension SCNVector3 {
    /// For Helper
    var __signRepr__: String {
        let xSign = Helper.getSignAsString(n: self.x)
        let ySign = Helper.getSignAsString(n: self.y)
        let zSign = Helper.getSignAsString(n: self.z)
        return "Vector(\(self.x), \(self.y), \(self.z)       \(xSign),\(ySign),\(zSign),"
    }
}
