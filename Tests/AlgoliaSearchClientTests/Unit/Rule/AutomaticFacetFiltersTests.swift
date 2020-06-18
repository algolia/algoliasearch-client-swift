//
//  AutomaticFacetFiltersTests.swift
//  
//
//  Created by Vladislav Fitc on 06/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class AutomaticFacetFiltersTests: XCTestCase {
  
  func testCoding() throws {
    try AssertEncodeDecode(Rule.AutomaticFacetFilters(attribute: "attr", score: 10, isDisjunctive: true), ["facet": "attr", "score": 10, "disjunctive": true])
    try AssertEncodeDecode(Rule.AutomaticFacetFilters(attribute: "attr2", score: 20, isDisjunctive: false), ["facet": "attr2", "score": 20, "disjunctive": false])
  }
  
}
