//
//  FacetStats.swift
//
//
//  Created by Vladislav Fitc on 16/03/2022.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class FacetStatsTests: XCTestCase {
  func testDecoding() throws {
    let jsonData = """
      {
        "min": 10,
        "max": 200,
        "avg": 105,
        "sum": 210,
      }
      """.data(using: .utf8)!
    let facetStats = try JSONDecoder().decode(FacetStats.self, from: jsonData)
    XCTAssertEqual(facetStats.min, 10)
    XCTAssertEqual(facetStats.max, 200)
    XCTAssertEqual(facetStats.avg, 105)
    XCTAssertEqual(facetStats.sum, 210)
  }

  func testMissingSumAvgDecoding() throws {
    let jsonData = """
      {
        "min": 10,
        "max": 200,
      }
      """.data(using: .utf8)!
    let facetStats = try JSONDecoder().decode(FacetStats.self, from: jsonData)
    XCTAssertEqual(facetStats.min, 10)
    XCTAssertEqual(facetStats.max, 200)
    XCTAssertNil(facetStats.avg)
    XCTAssertNil(facetStats.sum)
  }
}
