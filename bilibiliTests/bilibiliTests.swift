//
//  bilibiliTests.swift
//  bilibiliTests
//
//  Created by Apollo Zhu on 9/30/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

import XCTest

class bilibiliTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchLoginURL() {
        let goal = expectation(description: "Fetch Login URL")
        BKLogin.fetchLoginURL { result
            switch result {
            case .errored(let response, let error): print(response, error)
            case .success(let loginURL): print(loginURl.url)
            }
            goal.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
