//
//  JSONmanagerTests.swift
//  ARMeasureTests
//
//  Created by YOUNG on 07/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import XCTest
//import SwiftyJSON
import SwiftyJSON
@testable import ARMeasure

class JSONmanagerTests: XCTestCase {
    
    let jm = JSONManager.sharedInstance
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMainJSONExists() {
        
        XCTAssertNotNil(jm.json, "Main JSON doesn't exist")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
