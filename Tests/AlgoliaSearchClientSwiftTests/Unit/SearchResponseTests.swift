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
  
  func testDecoding() {
    let data = try! Data(filename: "SearchResponse.json")
    let decoder = JSONDecoder()
    do {
      _ = try decoder.decode(SearchResponse.self, from: data)
    } catch let error {
      XCTFail("\(error)")
    }
  
  }
  
}
