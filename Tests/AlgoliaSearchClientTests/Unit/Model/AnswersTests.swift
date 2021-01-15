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
      _ = AnswersQuery(query: "query", queryLanguages: [.english])
        .set(\.attributesToSnippet, to: [.init(attribute: "")])
    }
    expectingAssertionFailure(expectedMessage: "hitsPerPage is not supported by answers") {
      _ = AnswersQuery(query: "query", queryLanguages: [.english])
        .set(\.hitsPerPage, to: 20)
    }
    expectingAssertionFailure(expectedMessage: "restrictSearchableAttributes is not supported by answers") {
      _ = AnswersQuery(query: "query", queryLanguages: [.english])
        .set(\.restrictSearchableAttributes, to: ["a"])
    }
  }
  
  func testSpecificParams() throws {
    let query = AnswersQuery(query: "query", queryLanguages: [.english])
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
    let query = AnswersQuery(query: "query", queryLanguages: [.english])
      .set(\.filters, to: "brand:sony")
    let expectedQueryJSON: JSON = [
      "query": "query",
      "queryLanguages": ["en"],
      "params": [
        "filters": "brand:sony"
      ],
    ]
    try AssertEncodeDecode(query, expectedQueryJSON)
  }
  
}
