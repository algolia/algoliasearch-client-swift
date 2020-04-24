//
//  MultipleOperationsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 23/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class MultipleOperationsIntegrationTests: OnlineTestCase {
  
  override var indexNameSuffix: String? {
    return "exists"
  }
  
  lazy var firstIndex: Index = {
    return client.index(withName: "multiple_operations")
  }()
  
  lazy var secondIndex: Index = {
    return client.index(withName: "multiple_operations_dev")
  }()
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    try firstIndex.delete()
    try secondIndex.delete()
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    try firstIndex.delete()
    try secondIndex.delete()
  }
  
  func testMultipleOperationsTests() throws {
    
    let object: JSON = ["firstName": "Jimmie"]
    
    let response = try client.multipleBatchObjects(operations: [
      (firstIndex.name, .add(object)),
      (firstIndex.name, .add(object)),
      (secondIndex.name, .add(object)),
      (secondIndex.name, .add(object))])

    try WaitableBatchesResponse(client: client, batchesResponse: response).wait()

    let objectIDs = response.objectIDs.compactMap { $0 }

    XCTAssertEqual(objectIDs.count, 4)

    let objectsResponse = try client.multipleGetObjects(requests: [
      .init(indexName: firstIndex.name, objectID: objectIDs[0]),
      .init(indexName: firstIndex.name, objectID: objectIDs[1]),
      .init(indexName: secondIndex.name, objectID: objectIDs[2]),
      .init(indexName: secondIndex.name, objectID: objectIDs[3]),
    ])

    let objects = objectsResponse.results.compactMap { $0 }

    XCTAssertEqual(objects.count, 4)

    for object in objects {
      XCTAssertEqual(object["firstName"], "Jimmie")
    }
    
    
    let results = try client.multipleQueries(queries: [
      (firstIndex.name, Query.empty.set(\.hitsPerPage, to: 2)),
      (secondIndex.name, Query.empty.set(\.hitsPerPage, to: 2)),
    ], strategy: .none)
    
    XCTAssertEqual(results.count, 2)
    XCTAssertEqual(results[0].nbHits, 2)
    XCTAssertEqual(results[1].nbHits, 2)

    let resultsStopIfEnough = try client.multipleQueries(queries: [
      (firstIndex.name, Query.empty.set(\.hitsPerPage, to: 2)),
      (secondIndex.name, Query.empty.set(\.hitsPerPage, to: 2)),
    ], strategy: .stopIfEnoughMatches)

    XCTAssertEqual(resultsStopIfEnough.count, 2)
    XCTAssertEqual(resultsStopIfEnough[0].nbHits, 2)
    XCTAssertEqual(resultsStopIfEnough[1].nbHits, 0)
    
  }
  
}
