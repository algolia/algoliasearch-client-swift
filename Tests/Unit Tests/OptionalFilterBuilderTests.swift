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
        
        optionalFilterBuilder["a"][.and("x")] +++ ("brand", "sony")
        optionalFilterBuilder["b"][.or("y")] +++ ("brand", "apple")
        optionalFilterBuilder["c"][.and("z")] +++ ("size", 10) +++ ("featured", true)
        optionalFilterBuilder["c"][.or("n")] +++ ("country", "france") +++ ("color", "blue")
        
        let expectedA = "\"brand\":\"sony\""
        let expectedB = "\"brand\":\"apple\""
        let expectedC = "( \"color\":\"blue\" OR \"country\":\"france\" ) AND \"featured\":\"true\" AND \"size\":\"10.0\""
        
        XCTAssertEqual(optionalFilterBuilder.build(), [expectedA, expectedB, expectedC])
    }
    
    func testNegationIgnorance() {
        
        let optionalFilterBuilder = OptionalFilterBuilder()
        
        let filter1 = !FilterFacet(attribute: "brand", value: "huawei")
        let filter2 = !FilterFacet(attribute: "featured", value: false)
        let filter3 = !FilterFacet(attribute: "size", value: 50)
        
        optionalFilterBuilder["a"][.and("b")] +++ [filter1, filter2, filter3]
        
        XCTAssertEqual(optionalFilterBuilder.build(), ["\"brand\":\"huawei\" AND \"featured\":\"false\" AND \"size\":\"50.0\""])
        
    }

}
