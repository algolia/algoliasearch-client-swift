//
//  RuleTests.swift
//
//
//  Created by Vladislav Fitc on 06/05/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class RuleTests: XCTestCase {
  func testCoding() throws {
    let condition = Rule.Condition(
      anchoring: .is, pattern: .facet("testFacet"), context: "testContext", alternatives: false)

    let consequence = Rule.Consequence()
      .set(\.automaticFacetFilters, to: [.init(attribute: "attr", score: 10, isDisjunctive: true)])
      .set(
        \.automaticOptionalFacetFilters,
        to: [.init(attribute: "attr2", score: 20, isDisjunctive: false)]
      )
      .set(\.queryTextAlteration, to: .edits([.remove("a"), .replace("b", with: "c")]))
      .set(
        \.promote, to: [.init(objectID: "one", position: 10), .init(objectID: "two", position: 20)]
      )
      .set(\.filterPromotes, to: false)
      .set(\.hide, to: ["o1", "o2", "o3"])
      .set(\.userData, to: ["myKey": "myData"])

    let validity: [TimeRange] = [
      .init(
        from: .init(timeIntervalSince1970: 1_532_439_300),
        until: .init(timeIntervalSince1970: 1_532_525_700))
    ]

    let rule = Rule(objectID: "ruleObjectID")
      .set(\.conditions, to: [condition])
      .set(\.consequence, to: consequence)
      .set(\.isEnabled, to: true)
      .set(\.validity, to: validity)
      .set(\.description, to: "test description")

    try AssertEncodeDecode(
      rule,
      [
        "objectID": "ruleObjectID",
        "conditions": [
          [
            "anchoring": "is", "pattern": "{facet:testFacet}", "context": "testContext",
            "alternatives": false,
          ]
        ],
        "consequence": [
          "params": [
            "automaticFacetFilters": [["facet": "attr", "score": 10, "disjunctive": true]],
            "automaticOptionalFacetFilters": [
              ["facet": "attr2", "score": 20, "disjunctive": false]
            ],
            "query": [
              "edits": [
                ["type": "remove", "delete": "a"],
                ["type": "replace", "delete": "b", "insert": "c"],
              ]
            ],
          ],
          "promote": [["objectID": "one", "position": 10], ["objectID": "two", "position": 20]],
          "filterPromotes": false,
          "hide": [["objectID": "o1"], ["objectID": "o2"], ["objectID": "o3"]],
          "userData": ["myKey": "myData"],
        ],
        "enabled": true,
        "validity": [["from": 1_532_439_300, "until": 1_532_525_700]],
        "description": "test description",
      ])
  }

  func testLegacyDecoding() throws {
    let legacyRuleData = """
      {
        "objectID": "query_edits",
        "condition": {"anchoring": "is", "pattern": "mobile phone"},
        "consequence": {
          "params": {
            "query": {
             "remove": ["mobile", "phone"]
            }
          }
        }
      }
      """.data(using: .utf8)!

    let rule = try JSONDecoder().decode(Rule.self, from: legacyRuleData)

    guard case .edits(let edits) = rule.consequence?.queryTextAlteration else {
      XCTFail("Expected edits in consequence")
      return
    }

    XCTAssertEqual(edits, [.remove("mobile"), .remove("phone")])
  }
}
