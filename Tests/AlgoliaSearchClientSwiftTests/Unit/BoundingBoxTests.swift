//
//  BoundingBoxTests.swift
//
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class BoundingBoxTests: XCTestCase {

  func testDecoding() throws {
    try testDecoding([1, 2, 3, 4], expected: BoundingBox(point1: .init(latitude: 1, longitude: 2), point2: .init(latitude: 3, longitude: 4)))
  }

  func testEncoding() throws {
    try testEncoding(BoundingBox(point1: .init(latitude: 1, longitude: 2), point2: .init(latitude: 3, longitude: 4)), expected: [Float](arrayLiteral: 1, 2, 3, 4))
  }

}
