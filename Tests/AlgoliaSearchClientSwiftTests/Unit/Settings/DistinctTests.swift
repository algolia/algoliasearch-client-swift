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

  func testEncoding() throws {
    try testEncoding(1 as Distinct, expected: 1)
    try testEncoding(0 as Distinct, expected: 0)
    try testEncoding(100 as Distinct, expected: 100)
    try testEncoding(false as Distinct, expected: 0)
    try testEncoding(true as Distinct, expected: 1)
  }

  func testDecoding() throws {
    try testDecoding(1, expected: Distinct(1))
    try testDecoding(0, expected: Distinct(0))
    try testDecoding(100, expected: Distinct(100))
    try testDecoding(true, expected: Distinct(1))
    try testDecoding(false, expected: Distinct(0))
  }

}
