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

  func testDecoding() throws {
    try testDecoding("attr", expected: Snippet(attribute: "attr"))
    try testDecoding("attr:20", expected: Snippet(attribute: "attr", count: 20))
  }

  func testEncoding() throws {
    try testEncoding(Snippet(attribute: "attr"), expected: "attr")
    try testEncoding(Snippet(attribute: "attr", count: 20), expected: "attr:20")
  }

}
