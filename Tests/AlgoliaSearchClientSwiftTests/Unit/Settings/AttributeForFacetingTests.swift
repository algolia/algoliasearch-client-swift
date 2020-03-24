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

  func testDecoding() throws {
    try testDecoding("author", expected: AttributeForFaceting.default("author"))
    try testDecoding("filterOnly(category)", expected: AttributeForFaceting.filterOnly("category"))
    try testDecoding("searchable(publisher)", expected: AttributeForFaceting.searchable("publisher"))
  }

  func testEncoding() throws {
    try testEncoding(AttributeForFaceting.default("author"), expected: "author")
    try testEncoding(AttributeForFaceting.filterOnly("category"), expected: "filterOnly(category)")
    try testEncoding(AttributeForFaceting.searchable("publisher"), expected: "searchable(publisher)")
  }

}
