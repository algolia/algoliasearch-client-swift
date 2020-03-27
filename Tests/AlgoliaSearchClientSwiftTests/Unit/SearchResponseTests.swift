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
    AssertDecode(jsonFilename: "Facets.json", expected: SearchResponse.FacetsStorage.self)
  }

  func testDecodingFacetStats() {
    AssertDecode(jsonFilename: "FacetsStats.json", expected: SearchResponse.FacetStatsStorage.self)
  }

  func testDecoding() {
    AssertDecode(jsonFilename: "SearchResponse.json", expected: SearchResponse.self)
  }

}
