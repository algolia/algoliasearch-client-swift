//
//  FilterBuilderGroupTests.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 22/01/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchClient
import XCTest

class FilterBuilderGroupTests: XCTestCase {
    
    func testAndGroupSubscript() {
        let filterBuilder = FilterBuilder()
        
        let filter = FilterFacet(attribute: "category", value: "table")
        
        let group = AndFilterGroup(name: "group")
        
        filterBuilder[group] +++ filter
        
        XCTAssertTrue(filterBuilder.contains(filter))
        
        XCTAssertEqual(filterBuilder.build(), """
        "category":"table"
        """)
        
    }
    
    func testOrGroupSubscript() {
        let filterBuilder = FilterBuilder()
        
        let filter = FilterFacet(attribute: "category", value: "table")
        
        let group = OrFilterGroup<FilterFacet>(name: "group")
        
        filterBuilder[group] +++ filter
        
        XCTAssertTrue(filterBuilder.contains(filter))
        
        XCTAssertEqual(filterBuilder.build(), """
        "category":"table"
        """)
    }
    
    func testOrGroupAddAll() {
        let filterBuilder = FilterBuilder()
        let group = OrFilterGroup<FilterFacet>(name: "group")
        let filter1 = FilterFacet(attribute: "category", value: "table")
        let filter2 = FilterFacet(attribute: "category", value: "chair")
        filterBuilder.addAll([filter1, filter2], to: group)
        XCTAssertTrue(filterBuilder.contains(filter1))
        XCTAssertTrue(filterBuilder.contains(filter2))
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "category":"chair" OR "category":"table" )
        """)
    }
    
    func testAndGroupAddAll() {
        let filterBuilder = FilterBuilder()
        let group = AndFilterGroup(name: "group")
        let filterPrice = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterSize = FilterNumeric(attribute: "size", operator: .greaterThan, value: 20)
        filterBuilder.addAll([filterPrice, filterSize], to: group)
        XCTAssertTrue(filterBuilder.contains(filterPrice))
        XCTAssertTrue(filterBuilder.contains(filterSize))
        
        XCTAssertEqual(filterBuilder.build(), """
        "price" > 10.0 AND "size" > 20.0
        """)
    }
    
}
