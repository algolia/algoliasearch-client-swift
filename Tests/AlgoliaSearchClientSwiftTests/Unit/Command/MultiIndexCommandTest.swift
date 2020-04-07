//
//  MultiIndexCommandTest.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class MultiIndexCommandTest: XCTestCase, AlgoliaCommandTest {
  
  func testListIndices() {
    let command = Command.MultipleIndex.ListIndices(requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/indexes",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)

  }
  
  func testListAPIKeys() {
    let command = Command.MultipleIndex.ListIndexAPIKeys(requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/indexes/*/keys",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testQueries() {
    let command = Command.MultipleIndex.Queries(queries: [("index0", "query0"), ("index1", "query1")], strategy: .stopIfEnoughMatches, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/*/queries",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: MultipleQueriesRequest(requests: [.init(indexName: "index0", query: "query0"), .init(indexName: "index1", query: "query1")], strategy: .stopIfEnoughMatches).httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testGetObjects() {
    let command = Command.MultipleIndex.GetObjects(requests: [], requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/*/objects",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testBatchObjects() {
    let command = Command.MultipleIndex.BatchObjects(operations: [], requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/indexes/*/batch",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
}
