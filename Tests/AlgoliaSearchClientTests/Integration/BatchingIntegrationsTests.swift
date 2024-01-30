//
//  BatchingIntegrationTests.swift
//
//
//  Created by Vladislav Fitc on 21/04/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class BatchingIntegrationTests: IntegrationTestCase {
  override var indexNameSuffix: String? {
    "index_batching"
  }

  override var retryableTests: [() throws -> Void] {
    [batching]
  }

  func batching() throws {
    let records: [JSON] = [
      ["objectID": "one", "key": "value"],
      ["objectID": "two", "key": "value"],
      ["objectID": "three", "key": "value"],
      ["objectID": "four", "key": "value"],
      ["objectID": "five", "key": "value"],
    ]

    try index.saveObjects(records).wait()

    try index.batch([
      .add(["objectID": "zero", "key": "value"]),
      .update(objectID: "one", ["k": "v"] as JSON),
      .partialUpdate(objectID: "two", ["k": "v"] as JSON, createIfNotExists: true),
      .partialUpdate(objectID: "two_bis", ["key": "value"] as JSON, createIfNotExists: true),
      .partialUpdate(objectID: "three", ["k": "v"] as JSON, createIfNotExists: false),
      .delete(objectID: "four"),
    ]).wait()

    let results = try index.browse()
    let fetchedRecords: [JSON] = try results.extractHits()
    XCTAssertEqual(fetchedRecords.count, 6)
    XCTAssert(fetchedRecords.contains(["objectID": "zero", "key": "value"]))
    XCTAssert(fetchedRecords.contains(["objectID": "one", "k": "v"]))
    XCTAssert(fetchedRecords.contains(["objectID": "two", "k": "v", "key": "value"]))
    XCTAssert(fetchedRecords.contains(["objectID": "two_bis", "key": "value"]))
    XCTAssert(fetchedRecords.contains(["objectID": "three", "k": "v", "key": "value"]))
    XCTAssert(fetchedRecords.contains(["objectID": "five", "key": "value"]))
  }
}
