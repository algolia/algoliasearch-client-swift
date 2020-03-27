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

  func testCoding() throws {
    try AssertEncodeDecode(TypoTolerance.false, "false")
    try AssertEncodeDecode(TypoTolerance.true, "true")
    try AssertEncodeDecode(TypoTolerance.min, "min")
    try AssertEncodeDecode(TypoTolerance.strict, "strict")
  }

}
