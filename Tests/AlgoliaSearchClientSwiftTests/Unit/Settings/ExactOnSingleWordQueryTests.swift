//
//  ExactOnSingleWordQueryTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class ExactOnSingleWordQueryTests: XCTestCase {

  func testEncoding() throws {
    try testEncoding(ExactOnSingleWordQuery.attribute, expected: "attribute")
    try testEncoding(ExactOnSingleWordQuery.none, expected: "none")
    try testEncoding(ExactOnSingleWordQuery.word, expected: "word")
  }

  func testDecoding() throws {
    try testDecoding("attribute", expected: ExactOnSingleWordQuery.attribute)
    try testDecoding("none", expected: ExactOnSingleWordQuery.none)
    try testDecoding("word", expected: ExactOnSingleWordQuery.word)
  }

}
