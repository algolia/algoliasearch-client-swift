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
  
  func testEncoding() {
    testEncoding(SearchableAttribute.default(["title", "alternative_title", "emails.personal", "author"]), expected: "title,alternative_title,emails.personal,author")
    testEncoding(SearchableAttribute.unordered("text"), expected: "unordered(text)")
  }
  
  func testDecoding() {
    testDecoding("title,alternative_title,emails.personal,author", expected: SearchableAttribute.default(["title", "alternative_title", "emails.personal", "author"]))
    testDecoding("unordered(text)", expected: SearchableAttribute.unordered("text"))
  }
    
}
