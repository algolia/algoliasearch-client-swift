//
//  RuleConditionTests.swift
//
//
//  Created by Vladislav Fitc on 06/05/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class RuleConditionTests: XCTestCase {
  func testCoding() throws {
    var condition = Rule.Condition(
      anchoring: .is, pattern: .facet("testFacet"), context: "testContext", alternatives: false,
      filters: "brand:samsung")
    try AssertEncodeDecode(
      condition,
      [
        "anchoring": "is", "pattern": "{facet:testFacet}", "context": "testContext",
        "alternatives": false, "filters": "brand:samsung",
      ])

    condition = Rule.Condition(
      anchoring: .endsWith, pattern: .literal("testLiteral"), context: "testContext",
      alternatives: false, filters: "brand:samsung")
    try AssertEncodeDecode(
      condition,
      [
        "anchoring": "endsWith", "pattern": "testLiteral", "context": "testContext",
        "alternatives": false, "filters": "brand:samsung",
      ])
  }
}
