//
//  Constants.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 10/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import Foundation
import SceneKit

enum Settings {
    static let isDebugging = false
    static let cancelNoise = true
}

enum Constants {
    static let pi = Float(Double.pi)
    static let measureLineRadius: CGFloat = 0.005
    static let measureLineColor = UIColor.cyan
    
    static let measureLabelFontSizeSmall: CGFloat = 25
    static let measureLabelFontSizeLarge: CGFloat = 60
    static let measureLabelFontSizeXLarge: CGFloat = 80
    
    static let measurePlaneColor = UIColor(red: 0.7, green: 0.0, blue: 0.2, alpha: 0.5)
    
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    
    static let markerRadius:CGFloat = 0.01
    /// This is an empirical value
    static let epsilon:Float = 1e-5 //0.00001
}

enum Helper {
    static func getSignAsString<T>(n: T) -> String where T: Comparable, T: SignedNumeric {
        if n > 0 {
            return "+"
        } else if n == 0 {
            return "0"
        } else {
            return "-"
        }
    }
}
