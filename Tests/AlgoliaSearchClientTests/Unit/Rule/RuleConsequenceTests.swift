//
//  RuleConsequenceTests.swift
//  
//
//  Created by Vladislav Fitc on 06/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class RuleConsequenceTests: XCTestCase {
  
  func testCoding() throws {
    let consequence = Rule.Consequence()
      .set(\.automaticFacetFilters, to: [.init(attribute: "attr", score: 10, isDisjunctive: true)])
      .set(\.automaticOptionalFacetFilters, to: [.init(attribute: "attr2", score: 20, isDisjunctive: false)])
      .set(\.queryTextAlteration, to: .edits([.remove("a"), .replace("b", with: "c")]))
      .set(\.query, to: Query.empty
        .set(\.filters, to: "filter:value")
        .set(\.sortFacetsBy, to: .alpha))
      .set(\.promote, to: [.init(objectID: "one", position: 10), .init(objectID: "two", position: 20)])
      .set(\.filterPromotes, to: false)
      .set(\.hide, to: ["o1", "o2", "o3"])
      .set(\.userData, to: ["myKey": "myData"])

    try AssertEncodeDecode(consequence, [
      "params": [
        "sortFacetValuesBy": "alpha",
        "filters": "filter:value",
        "automaticFacetFilters": [["facet": "attr", "score": 10, "disjunctive": true]],
        "automaticOptionalFacetFilters": [["facet": "attr2", "score": 20, "disjunctive": false]],
        "query": ["edits": [["type": "remove", "delete": "a"], ["type": "replace", "delete": "b", "insert": "c"]]],
      ],
      "promote": [["objectID": "one", "position": 10], ["objectID": "two", "position": 20]],
      "filterPromotes": false,
      "hide": [["objectID": "o1"], ["objectID": "o2"], ["objectID": "o3"]],
      "userData": ["myKey": "myData"],
    ])
    
  }
  
  func testEditsDecoding() throws {
    let data = """
    {
      "filterPromotes" : false,
      "params" : {
        "filters" : "brand:OnePlus",
        "query" : {
          "edits" : [
            {
              "delete" : "mobile",
              "type" : "remove"
            },
            {
              "delete" : "phone",
              "insert" : "iphone",
              "type" : "replace"
            }
          ]
        }
      }
    }
    """.data(using: .utf8)!
    XCTAssertNoThrow(try JSONDecoder().decode(Rule.Consequence.self, from: data))
  }
  
}
