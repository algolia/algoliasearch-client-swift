//
//  NumericAttributeFilterTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class NumericAttributeFilterTests: XCTestCase {

  func testEncoding() throws {
    try testEncoding(NumericAttributeFilter.default("attr"), expected: "attr")
    try testEncoding(NumericAttributeFilter.equalOnly("attr"), expected: "equalOnly(attr)")

  }

  func testDecoding() throws {
    try testDecoding("attr", expected: NumericAttributeFilter.default("attr"))
    try testDecoding("equalOnly(attr)", expected: NumericAttributeFilter.equalOnly("attr"))
  }

}
