//
//  DistinctTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class DistinctTests: XCTestCase {

  func testEncoding() {
    testEncoding(1 as Distinct, expected: 1)
    testEncoding(0 as Distinct, expected: 0)
    testEncoding(100 as Distinct, expected: 100)
    testEncoding(false as Distinct, expected: 0)
    testEncoding(true as Distinct, expected: 1)
  }
  
  func testDecoding() {
    testDecoding(1, expected: Distinct(1))
    testDecoding(0, expected: Distinct(0))
    testDecoding(100, expected: Distinct(100))
    testDecoding(true, expected: Distinct(1))
    testDecoding(false, expected: Distinct(0))
  }
  
}
