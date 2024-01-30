//
//  ObjectIDCheckerTests.swift
//
//
//  Created by Vladislav Fitc on 29/04/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class ObjectIDCheckerTests: XCTestCase {
  struct ObjectWithID: Codable {
    let objectID: String
    let value: String
  }

  struct ObjectWithoutID: Codable {
    let value: String
  }

  func testCheck() {
    XCTAssertThrowsError(try ObjectIDChecker.checkObjectID(ObjectWithoutID(value: "")))
    XCTAssertThrowsError(try ObjectIDChecker.checkObjectID(["value": ""] as JSON))
    XCTAssertNoThrow(try ObjectIDChecker.checkObjectID(["objectID": "", "value": ""] as JSON))
    XCTAssertNoThrow(try ObjectIDChecker.checkObjectID(ObjectWithID(objectID: "", value: "")))
    XCTAssertNoThrow(
      try ObjectIDChecker.checkObjectID(
        ObjectWrapper(objectID: "", object: ObjectWithoutID(value: ""))))
  }
}
