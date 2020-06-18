//
//  PointTests.swift
//  
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class PointTests: XCTestCase {

  func testCoding() throws {
    try AssertEncodeDecode(Point(latitude: 2, longitude: 3), "2.0,3.0")
  }

}
