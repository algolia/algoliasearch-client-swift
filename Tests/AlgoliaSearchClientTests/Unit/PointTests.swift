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

  func testStringDecoding() throws {
    try AssertDecode(
      "22.2268517,84.84634989999999",
      expected: Point(latitude: 22.2268517, longitude: 84.84634989999999))
  }

  func testDictionaryDecoding() throws {
    try AssertDecode(
      ["lat": 22.2268517, "lng": 84.84634989999999],
      expected: Point(latitude: 22.2268517, longitude: 84.84634989999999))
  }

  func testFailedDecoding() throws {
    let json: JSON = ["lat": 22.2268517, "lon": 84.84634989999999]
    let data = try JSONEncoder().encode(json)
    let decoder = JSONDecoder()
    XCTAssertThrowsError(try decoder.decode(Point.self, from: data), "")
  }
}
