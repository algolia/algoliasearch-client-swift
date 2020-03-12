//
//  TypoToleranceTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class TypoToleranceTests: XCTestCase {
  
  func testEncoding() {
    testEncoding(TypoTolerance.false, expected: String(false))
    testEncoding(TypoTolerance.true, expected: String(true))
    testEncoding(TypoTolerance.min, expected: "min")
    testEncoding(TypoTolerance.strict, expected: "strict")
  }
  
  func testDecoding() {
    testDecoding(String(false), expected: TypoTolerance.false)
    testDecoding(String(true), expected: TypoTolerance.true)
    testDecoding("min", expected: TypoTolerance.min)
    testDecoding("strict", expected: TypoTolerance.strict)
  }
  
}
