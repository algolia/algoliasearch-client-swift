//
//  PointTests.swift
//  
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class PointTests: XCTestCase {
  
  func testDecoding() {
    testDecoding("2.0,3.0", expected: Point(latitude: 2, longitude: 3))
  }
  
  func testEncoding() {
    testEncoding(Point(latitude: 2, longitude: 3), expected: "2.0,3.0")
  }
  
}
