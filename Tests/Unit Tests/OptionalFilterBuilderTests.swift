//
//  OptionalFilterBuilderTests.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 27/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation
import InstantSearchClient
import XCTest

class OptionalFilterBuilderTests: XCTestCase {

    func testBuilding() {
        
        let optionalFilterBuilder = OptionalFilterBuilder()
    
        optionalFilterBuilder[.and("a")] +++ ("brand", "sony")
        optionalFilterBuilder[.or("b")] +++ ("brand", "apple")
        optionalFilterBuilder[.or("c")] +++ ("size", 10) +++ ("featured", true)
        optionalFilterBuilder[.or("d")] +++ ("country", "france") +++ ("color", "blue")
        
        let expectedA = "\"brand\":\"sony\""
        let expectedB = "\"brand\":\"apple\""
        let expectedC = ["\"featured\":\"true\"", "\"size\":\"10.0\""]
        let expectedD = ["\"color\":\"blue\"", "\"country\":\"france\""]
        
        XCTAssertEqual(optionalFilterBuilder.build().count, 4)
        XCTAssertEqual(optionalFilterBuilder.build().compactMap { $0 as? String }, [expectedA, expectedB])
        XCTAssertEqual(optionalFilterBuilder.build().compactMap { $0 as? [String] }, [expectedC, expectedD])

    }
    
    func testNegationIgnorance() {
        
        let optionalFilterBuilder = OptionalFilterBuilder()
        
        let filter1 = !FilterFacet(attribute: "brand", value: "huawei")
        let filter2 = !FilterFacet(attribute: "featured", value: false)
        let filter3 = !FilterFacet(attribute: "size", value: 50)
        
        optionalFilterBuilder[.and("a")] +++ [filter1, filter2, filter3]
        
        XCTAssertEqual(optionalFilterBuilder.build().count, 3)
        XCTAssertEqual(optionalFilterBuilder.build().compactMap { $0 as? String }, ["\"brand\":\"huawei\"", "\"featured\":\"false\"", "\"size\":\"50.0\""])
        
    }

}
