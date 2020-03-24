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

  func testEncoding() throws {
    try testEncoding(TypoTolerance.false, expected: String(false))
    try testEncoding(TypoTolerance.true, expected: String(true))
    try testEncoding(TypoTolerance.min, expected: "min")
    try testEncoding(TypoTolerance.strict, expected: "strict")
  }

  func testDecoding() throws {
    try testDecoding(String(false), expected: TypoTolerance.false)
    try testDecoding(String(true), expected: TypoTolerance.true)
    try testDecoding("min", expected: TypoTolerance.min)
    try testDecoding("strict", expected: TypoTolerance.strict)
  }

}
