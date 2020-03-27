//
//  SearchableAttributeTests.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SearchableAttributeTests: XCTestCase {
  
  func testCoding() throws {
    try AssertEncodeDecode(SearchableAttribute.default(["title", "alternative_title", "emails.personal", "author"]), "title,alternative_title,emails.personal,author")
    try AssertEncodeDecode(SearchableAttribute.unordered("text"), "unordered(text)")
  }

}
