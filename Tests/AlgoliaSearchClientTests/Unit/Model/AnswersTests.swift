//
//  AnswersTests.swift
//  
//
//  Created by Vladislav Fitc on 20/11/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class AnswersQueryTests: XCTestCase {
  
  func testInvalidParametersAsserts() throws {
    expectingAssertionFailure(expectedMessage: "attributesToSnippet is not supported by answers") {
      _ = AnswersQuery(query: "query")
        .set(\.attributesToSnippet, to: [.init(attribute: "")])
    }
    expectingAssertionFailure(expectedMessage: "hitsPerPage is not supported by answers") {
      _ = AnswersQuery(query: "query")
        .set(\.hitsPerPage, to: 20)
    }
    expectingAssertionFailure(expectedMessage: "restrictSearchableAttributes is not supported by answers") {
      _ = AnswersQuery(query: "query")
        .set(\.restrictSearchableAttributes, to: ["a"])
    }
  }
  
  func testSpecificParams() throws {
    let query = AnswersQuery(query: "query")
      .set(\.queryLanguages, to: [.english])
      .set(\.attributesForPrediction, to: ["a1", "a2"])
      .set(\.nbHits, to: 10)
      .set(\.threshold, to: 20)
    let expectedQueryJSON: JSON = [
      "queryLanguages": ["en"],
      "query": "query",
      "nbHits": 10,
      "attributesForPrediction": ["a1", "a2"],
      "threshold": 20
    ]
    try AssertEncodeDecode(query, expectedQueryJSON)
  }
  
  func testSearchParams() throws {
    let query = AnswersQuery(query: "query")
      .set(\.filters, to: "brand:sony")
    let expectedQueryJSON: JSON = [
      "query": "query",
      "params": [
        "filters": "brand:sony"
      ],
    ]
    try AssertEncodeDecode(query, expectedQueryJSON)
  }
  
}
