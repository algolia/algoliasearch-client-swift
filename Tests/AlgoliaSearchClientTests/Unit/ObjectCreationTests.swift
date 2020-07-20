//
//  ObjectCreationTests.swift
//  
//
//  Created by Vladislav Fitc on 06/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class ObjectCreationTests: XCTestCase {

  func testCoding() throws {
    // Complicated date initialization to avoid JSON comparison failure
    let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970.rounded())
    try AssertEncodeDecode(ObjectCreation(createdAt: date, taskID: "16657823001", objectID: "5117231"), [
      "createdAt": .init(date),
      "objectID": "5117231",
      "taskID": "16657823001"
    ])
  }

}
