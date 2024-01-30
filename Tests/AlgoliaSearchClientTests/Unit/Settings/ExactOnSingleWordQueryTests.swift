//
//  ExactOnSingleWordQueryTests.swift
//
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class ExactOnSingleWordQueryTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(ExactOnSingleWordQuery.attribute, "attribute")
    try AssertEncodeDecode(ExactOnSingleWordQuery.none, "none")
    try AssertEncodeDecode(ExactOnSingleWordQuery.word, "word")
  }
}
