//
//  BoundingBoxTests.swift
//
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class BoundingBoxTests: XCTestCase {

  func testCoding() throws {
    try AssertEncodeDecode(BoundingBox(point1: .init(latitude: 1, longitude: 2), point2: .init(latitude: 3, longitude: 4)), [1, 2, 3, 4])
  }

}
