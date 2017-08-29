//
//  Float+Double+Extensions.swift
//  ARMeasure
//
//  Created by YOUNG on 28/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//


import Foundation



//public protocol AlmostEquatable {
//    static func ==~(lhs: Self, rhs: Self) -> Bool
//}

public protocol EquatableWithinEpsilon: Strideable {
    static var Epsilon: Self.Stride { get }
}

extension Float: EquatableWithinEpsilon {
    public static let Epsilon: Float.Stride = 1e-8
}

extension Double: EquatableWithinEpsilon {
    public static let Epsilon: Double.Stride = 1e-16
}

extension Float {
    /**
     https://twistedape.me.uk/blog/2016/02/02/comparing-floating-point-numbers/
     */
    public func isAlmostEqual(other: Float) -> Bool {
//        var epsilon: Float
//
//        if (self == other) {
//            return true
//        }
//
//        if (self > other) {
//            epsilon = self * .ulpOfOne * 10
//        } else {
//            epsilon = other * .ulpOfOne * 10
//        }
//        print("Epsilon: \(epsilon), e: \(Float.ulpOfOne)")
        return fabs(self - other) < .ulpOfOne
    }
}

//private func almostEqual<T: EquatableWithinEpsilon>(lhs: T, _ rhs: T, epsilon: T.Stride) -> Bool {
//    return abs(lhs - rhs) <= epsilon
//}
//
///** Almost-equality of floating point types. */
//infix operator ==~ { associativity left precedence 130 }
//public func ==~<T: protocol<AlmostEquatable, EquatableWithinEpsilon>>(lhs: T, rhs: T) -> Bool {
//    return almostEqual(lhs, rhs, epsilon: T.Epsilon)
//}
//
///** Inverse almost-equality for any AlmostEquatable. */
//infix operator !==~ { associativity left precedence 130 }
//public func !==~<T: AlmostEquatable>(lhs: T, rhs: T) -> Bool {
//    return !(lhs ==~ rhs)
//}

