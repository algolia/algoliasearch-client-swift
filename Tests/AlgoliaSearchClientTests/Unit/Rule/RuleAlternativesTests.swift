//
//  RuleAlternativesTests.swift
//
//
//  Created by Vladislav Fitc on 17/07/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class RuleAlternativesTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(Rule.Alternatives.true, true)
    try AssertEncodeDecode(Rule.Alternatives.false, false)
    try AssertDecode("true", expected: Rule.Alternatives.true)
    try AssertDecode("false", expected: Rule.Alternatives.false)
  }
}
