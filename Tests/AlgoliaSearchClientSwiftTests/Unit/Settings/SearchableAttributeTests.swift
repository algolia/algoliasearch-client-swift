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

  func testEncoding() throws {
    try testEncoding(SearchableAttribute.default(["title", "alternative_title", "emails.personal", "author"]), expected: "title,alternative_title,emails.personal,author")
    try testEncoding(SearchableAttribute.unordered("text"), expected: "unordered(text)")
  }

  func testDecoding() throws {
    try testDecoding("title,alternative_title,emails.personal,author", expected: SearchableAttribute.default(["title", "alternative_title", "emails.personal", "author"]))
    try testDecoding("unordered(text)", expected: SearchableAttribute.unordered("text"))
  }

}
