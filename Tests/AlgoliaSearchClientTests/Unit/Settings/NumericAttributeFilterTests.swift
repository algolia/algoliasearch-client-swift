//
//  NumericAttributeFilterTests.swift
//
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class NumericAttributeFilterTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(NumericAttributeFilter.default("attr"), "attr")
    try AssertEncodeDecode(NumericAttributeFilter.equalOnly("attr"), "equalOnly(attr)")
  }
}
