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
  
  func testEncoding() {
    testEncoding(NumericAttributeFilter.default("attr"), expected: "attr")
    testEncoding(NumericAttributeFilter.equalOnly("attr"), expected: "equalOnly(attr)")

  }
  
  func testDecoding() {
    testDecoding("attr", expected: NumericAttributeFilter.default("attr"))
    testDecoding("equalOnly(attr)", expected: NumericAttributeFilter.equalOnly("attr"))
  }
  
}
