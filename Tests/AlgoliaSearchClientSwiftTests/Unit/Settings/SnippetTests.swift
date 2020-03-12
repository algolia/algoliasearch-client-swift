//
//  SnippetTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SnippetTests: XCTestCase {
  
  func testDecoding() {
    testDecoding("attr", expected: Snippet(attribute: "attr"))
    testDecoding("attr:20", expected: Snippet(attribute: "attr", count: 20))
  }
  
  func testEncoding() {
    testEncoding(Snippet(attribute: "attr"), expected: "attr")
    testEncoding(Snippet(attribute: "attr", count: 20), expected: "attr:20")
  }
  
}
