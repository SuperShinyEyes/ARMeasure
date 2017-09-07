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
    
    func testSetupJSON() {
        XCTAssertNotNil(jm.json, "Main JSON doesn't exist")
    }
    
    func testAppend() {
        
        let left: JSON = [ "data":
            [[
            "screenShotName":"2017-09-06T11:38:09.011Z",
            "worldCoordinates":[[1, 2, 3]],
            "screenCoordinates":[[2, 3]]
            ]]
        ]
        
        let right: JSON = [ "data":
            [[
                "screenShotName":"100",
                "worldCoordinates":[[100, 2, 3]],
                "screenCoordinates":[[200, 3]]
                ]]
        ]
        
        guard let merged = jm.append(left: left, right: right) else {
            Logger.log("Append returned nil", event: .error)
            return
        }
        
        XCTAssertTrue(merged["data"].exists(), "Data exists")
        XCTAssertEqual(merged["data", 0], left["data", 0])
        XCTAssertNotEqual(merged["data", 1], left["data", 0])
    }
    
    func testAppend2() {
        
        let left: JSON = [ "data":
            [[
                "screenShotName":"2017-09-06T11:38:09.011Z",
                "worldCoordinates":[[1, 2, 3]],
                "screenCoordinates":[[2, 3]]
                ]]
        ]
        
        let right: JSON = [ "data":
            [[
                "screenShotName":"100",
                "worldCoordinates":[[100, 2, 3]],
                "screenCoordinates":[[200, 3]]
                ]]
        ]
        
        guard let merged = jm.append(left: left, right: right) else {
            return
        }
        
        let right2: JSON = [ "data":
            [[
                "screenShotName":"10000",
                "worldCoordinates":[[1000, 2, 3]],
                "screenCoordinates":[[200, 3]]
                ]]
        ]
        
        guard let merged2 = jm.append(left: merged, right: right2) else { return }
        
        XCTAssertTrue(merged["data"].exists(), "Data exists")
        XCTAssertEqual(merged2["data"].arrayObject?.count, 3)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
