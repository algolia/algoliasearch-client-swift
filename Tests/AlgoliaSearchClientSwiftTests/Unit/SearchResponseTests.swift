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

  func testDecodingFacets() throws {
    let facets = try AssertDecode(jsonFilename: "Facets.json", expected: FacetsStorage.self).storage
    XCTAssertEqual(facets.count, 11)
    XCTAssert(facets.keys.contains("type"))    
  }

  func testDecodingFacetStats() throws {
    try AssertDecode(jsonFilename: "FacetsStats.json", expected: SearchResponse.FacetStatsStorage.self)
  }

  func testDecoding() throws {
    try AssertDecode(jsonFilename: "SearchResponse.json", expected: SearchResponse.self)
  }

}
