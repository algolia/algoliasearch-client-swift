//
//  IndexingIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class IndexingIntegrationTests: OnlineTestCase {

  func testSaveGetObject() throws {

    let object: JSON = [
      "testField1": "testValue1",
      "testField2": 2,
      "testField3": true]

    let creation = try index.saveObject(record: object)
    _ = try index.wait(for: creation)
    let fetchedObject: JSON = try index.getObject(withID: creation.objectID)
    XCTAssertEqual(fetchedObject["testField1"], "testValue1")
    XCTAssertEqual(fetchedObject["testField2"], 2)
    XCTAssertEqual(fetchedObject["testField3"], true)
  }

  func testSaveGetObjectCallback() {

    let object: JSON = [
      "testField1": "testValue1",
      "testField2": 2,
      "testField3": true]

    let expectation = self.expectation(description: "Save-Wait-Create")

    index.saveObject(record: object, completion: extract { creation in
      self.index.waitTask(withID: creation.taskID, completion: extract { _ in
        self.index.getObject(withID: creation.objectID, completion: extract { (fetchedObject: JSON) in
          XCTAssertEqual(fetchedObject["testField1"], "testValue1")
          XCTAssertEqual(fetchedObject["testField2"], 2)
          XCTAssertEqual(fetchedObject["testField3"], true)
          expectation.fulfill()

        })
      })
    })

    waitForExpectations(timeout: expectationTimeout, handler: .none)

  }

}
