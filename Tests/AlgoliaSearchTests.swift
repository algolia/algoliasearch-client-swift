//
//  AlgoliaSearchTests.swift
//  AlgoliaSearchTests
//
//  Created by Thibault Deutsch on 13/02/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

import XCTest
import AlgoliaSearch
import Alamofire

class AlgoliaSearchTests: XCTestCase {
    var client: Client!
    
    override func setUp() {
        super.setUp()
        client = AlgoliaSearch.Client(appID: "XXX", apiKey: "XXX")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testListIndexes() {
        let expectation = expectationWithDescription("List indexes")
        client.listIndexes { (client, JSON, error) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, error!.localizedDescription)
        }
        
        waitForExpectationsWithTimeout(100, handler: nil)
    }
}
