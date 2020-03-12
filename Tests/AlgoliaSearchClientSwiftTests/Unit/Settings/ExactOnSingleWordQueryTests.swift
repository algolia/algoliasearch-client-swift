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
  
  func testEncoding() {
    testEncoding(ExactOnSingleWordQuery.attribute, expected: "attribute")
    testEncoding(ExactOnSingleWordQuery.none, expected: "none")
    testEncoding(ExactOnSingleWordQuery.word, expected: "word")
  }
  
  func testDecoding() {
    testDecoding("attribute", expected: ExactOnSingleWordQuery.attribute)
    testDecoding("none", expected: ExactOnSingleWordQuery.none)
    testDecoding("word", expected: ExactOnSingleWordQuery.word)
  }

  
}
