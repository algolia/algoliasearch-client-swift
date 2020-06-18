//
//  DistinctTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class DistinctTests: XCTestCase {

  func testCoding() throws {
    try AssertEncodeDecode(1 as Distinct, 1)
    try AssertEncodeDecode(0 as Distinct, 0)
    try AssertEncodeDecode(100 as Distinct, 100)
    try AssertEncodeDecode(false as Distinct, 0)
    try AssertEncodeDecode(true as Distinct, 1)
  }

}
