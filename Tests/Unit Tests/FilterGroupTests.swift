//
//  FilterGroupTests.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 16/01/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import XCTest
@testable import InstantSearchClient

class FilterGroupTests: XCTestCase {
    
    func testComparison() {
        XCTAssertEqual(AndFilterGroup(name: "a"), AndFilterGroup(name: "a"))
        XCTAssertNotEqual(AndFilterGroup(name: "a"), AndFilterGroup(name: "b"))
        XCTAssertEqual(OrFilterGroup<FilterFacet>(name: "a"), OrFilterGroup<FilterFacet>(name: "a"))
        XCTAssertNotEqual(OrFilterGroup<FilterFacet>(name: "a"), OrFilterGroup<FilterFacet>(name: "b"))
        
    }
    
    func testTypeErasedComparison() {
        
        XCTAssertEqual(AnyFilterGroup(AndFilterGroup(name: "a")), AnyFilterGroup(AndFilterGroup(name: "a")))
        XCTAssertNotEqual(AnyFilterGroup(AndFilterGroup(name: "a")), AnyFilterGroup(AndFilterGroup(name: "b")))
        XCTAssertEqual(AnyFilterGroup(OrFilterGroup<FilterFacet>(name: "a")), AnyFilterGroup(OrFilterGroup<FilterFacet>(name: "a")))
        XCTAssertNotEqual(AnyFilterGroup(OrFilterGroup<FilterFacet>(name: "a")), AnyFilterGroup(OrFilterGroup<FilterFacet>(name: "b")))
        XCTAssertNotEqual(AnyFilterGroup(OrFilterGroup<FilterFacet>(name: "a")), AnyFilterGroup(AndFilterGroup(name: "b")))
        
    }
    
    func testTypeErasedFlags() {
        XCTAssertTrue(AnyFilterGroup(AndFilterGroup(name: "a")).isConjunctive)
        XCTAssertFalse(AnyFilterGroup(AndFilterGroup(name: "a")).isDisjunctive)
        XCTAssertFalse(AnyFilterGroup(OrFilterGroup<FilterFacet>(name: "a")).isConjunctive)
        XCTAssertTrue(AnyFilterGroup(OrFilterGroup<FilterFacet>(name: "a")).isDisjunctive)
    }
    
}
