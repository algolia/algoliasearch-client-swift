//
//  HTMLHighlightingTest.swift
//  
//
//  Created by Vladislav Fitc on 11/09/2020.
//

import Foundation
import AlgoliaSearchClient
import XCTest

class HTMLHighlightingTest: XCTestCase {
  
  struct MarkupString: Codable {
    let source: String
    let markup: HighlightedString
  }
  
  func testHighlighting() throws {
    let data = try Data(filename: "HighlightedHTML.json")
    let searchResponse = try JSONDecoder().decode(MarkupString.self, from: data)
    let searchResponseJSON = try JSON(searchResponse)
    print(searchResponseJSON)
  }
  
}


