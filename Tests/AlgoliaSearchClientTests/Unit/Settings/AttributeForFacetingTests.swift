//
//  AttributeForFacetingTests.swift
//
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class AttributeForFacetingTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(AttributeForFaceting.default("author"), "author")
    try AssertEncodeDecode(AttributeForFaceting.filterOnly("category"), "filterOnly(category)")
    try AssertEncodeDecode(AttributeForFaceting.searchable("publisher"), "searchable(publisher)")
  }
}
