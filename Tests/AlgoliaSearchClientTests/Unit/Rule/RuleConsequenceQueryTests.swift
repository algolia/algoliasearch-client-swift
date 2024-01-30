//
//  RuleConsequenceQueryTests.swift
//
//
//  Created by Vladislav Fitc on 06/05/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class RuleConsequenceQueryTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(
      Rule.Consequence.QueryTextAlteration.edits([.remove("str1"), .replace("str2", with: "str3")]),
      [
        "edits": [
          ["type": "remove", "delete": "str1"],
          ["type": "replace", "delete": "str2", "insert": "str3"],
        ]
      ])
    try AssertEncodeDecode(
      Rule.Consequence.QueryTextAlteration.replacement("queryReplacement"), "queryReplacement")
  }
}
