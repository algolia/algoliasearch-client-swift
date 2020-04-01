//
//  IndexingCommandsTests.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class IndexingCommandsTests: XCTestCase, AlgoliaCommandTest {
  
  func testSaveObject() {
    let command = Command.Indexing.SaveObject(indexName: test.indexName, record: test.record, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/indexes/testIndex",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: test.record.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testGetObject() {
    let command = Command.Indexing.GetObject(indexName: test.indexName, objectID: test.objectID, attributesToRetrieve: test.attributes, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/indexes/testIndex/testObjectID",
          queryItems: [.init(name: "testParameter", value: "testParameterValue"), .init(name: "attributesToRetreive", value: "attr1,attr2")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testGetObjects() {
    let command = Command.Indexing.GetObjects(indexName: test.indexName,
                                              objectIDs: test.objectIDs,
                                              attributesToRetreive: test.attributes,
                                              requestOptions: test.requestOptions)
    let body = FieldWrapper(requests: test.objectIDs.map { ObjectRequest(indexName: test.indexName, objectID: $0, attributesToRetrieve: test.attributes) }).httpBody
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/testIndex/*/objects",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: body,
          requestOptions: test.requestOptions)
  }
  
  func testReplaceObject() {
    let command = Command.Indexing.ReplaceObject(indexName: test.indexName, objectID: test.objectID, replacementObject: test.record, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .put,
          urlPath: "/1/indexes/testIndex/testObjectID",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: test.record.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testBatch() {
    let command = Command.Index.Batch(indexName: test.indexName, batchOperations: test.batchOperations, requestOptions: test.requestOptions)
    let body = FieldWrapper(requests: test.batchOperations).httpBody
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/indexes/testIndex/batch",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: body,
          requestOptions: test.requestOptions)
  }
  
  func testDelete() {
    let command = Command.Index.DeleteIndex(indexName: test.indexName, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .delete,
          urlPath: "/1/indexes/testIndex",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
}
