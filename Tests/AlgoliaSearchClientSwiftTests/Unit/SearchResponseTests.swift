//
//  SearchResponseTests.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SearchResponseTests: XCTestCase {
  
  func testDecodingFacets() {
    XCTAssertNoThrow(try testDecoding(fromFileWithName: "Facets.json") as SearchResponse.FacetsStorage)
  }
  
  func testDecodingFacetStats() {
    XCTAssertNoThrow(try testDecoding(fromFileWithName: "FacetsStats.json") as SearchResponse.FacetStatsStorage)
  }
  
  func testDecoding() {
    XCTAssertNoThrow(try testDecoding(fromFileWithName: "SearchResponse.json") as SearchResponse)
  }
  
}
