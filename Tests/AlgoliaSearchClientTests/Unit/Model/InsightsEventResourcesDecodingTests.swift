//
//  InsightsEventResourcesDecodingTests.swift
//
//
//  Created by Vladislav Fitc on 21/07/2022.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class InsightsEventResourcesDecodingTests: XCTestCase {
  func testDecodeObjectIDs() throws {
    try AssertEncodeDecode(
      InsightsEvent.Resources.objectIDs(["object1", "object2", "object3"]),
      [
        "objectIDs": ["object1", "object2", "object3"]
      ])
  }

  func testDecodeObjectIDsWithPositions() throws {
    try AssertEncodeDecode(
      InsightsEvent.Resources.objectIDsWithPositions([
        ("object1", 1), ("object2", 2), ("object3", 3),
      ]),
      [
        "objectIDs": ["object1", "object2", "object3"],
        "positions": [1, 2, 3],
      ])
  }

  func testDecodeFilters() throws {
    try AssertEncodeDecode(
      InsightsEvent.Resources.filters(["f1", "f2", "f3"]),
      [
        "filters": ["f1", "f2", "f3"]
      ])
  }

  func testDecodingFailure() {
    let data = """
      {
        "foo": "bar"
      }
      """.data(using: .utf8)!
    XCTAssertThrowsError(
      try JSONDecoder().decode(InsightsEvent.Resources.self, from: data),
      "must throw decoding error"
    ) { error in
      guard case .dataCorrupted(let context) = error as? DecodingError,
        context.underlyingError is CompositeError
      else {
        XCTFail("unexpected error thrown")
        return
      }
    }
  }
}
