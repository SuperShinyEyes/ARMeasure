//
//  Int+Extensions.swift
//  ARMeasure
//
//  Created by YOUNG on 07/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

extension Int {
    public static var randomPositive: Int {
        return Int(arc4random())
    }
}
