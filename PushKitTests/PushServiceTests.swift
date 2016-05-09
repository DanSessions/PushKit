//
//  PushServiceTests.swift
//  Gather
//
//  Created by Dan on 5/8/16.
//  Copyright © 2016 Daniel Sessions. All rights reserved.
//

import XCTest
@testable import PushKit

class PushServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInvalidKey() {
        let key = "somekey"
        let pushService = PushService(key: key)
        let expectation = expectationWithDescription("PushService did not connect because of InvalidKey error")
        
        pushService.connectionFailed = {(error) in
            if error == Error.InvalidKey {
                expectation.fulfill()
            }
        }
        
        do {
            try pushService.connect()
        } catch {
            XCTFail("PushService did not connect")
        }
        
        waitForExpectationsWithTimeout(10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testConnect() {
        let key = "5f19d9f8b53b2670dad3"
        let pushService = PushService(key: key)
        let expectation = expectationWithDescription("PushService connected")
        
        pushService.didConnect = {
            expectation.fulfill()
        }
        
        do {
            try pushService.connect()
        } catch {
            XCTFail("PushService did not connect")
        }
        
        waitForExpectationsWithTimeout(10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
}
