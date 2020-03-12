//
//  AttributeForFacetingTests.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class AttributeForFacetingTests: XCTestCase {
  
  func testDecoding() {
    testDecoding("author", expected: AttributeForFaceting.default("author"))
    testDecoding("filterOnly(category)", expected: AttributeForFaceting.filterOnly("category"))
    testDecoding("searchable(publisher)", expected: AttributeForFaceting.searchable("publisher"))
  }
  
  func testEncoding() {
    testEncoding(AttributeForFaceting.default("author"), expected: "author")
    testEncoding(AttributeForFaceting.filterOnly("category"), expected: "filterOnly(category)")
    testEncoding(AttributeForFaceting.searchable("publisher"), expected: "searchable(publisher)")
  }
    
}
