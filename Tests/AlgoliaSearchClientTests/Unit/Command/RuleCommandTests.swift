//
//  RuleCommandTest.swift
//  
//
//  Created by Vladislav Fitc on 07/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class RuleCommandTests: XCTestCase, AlgoliaCommandTest {

  func testSave() {
    let rule = test.rule
    let command = Command.Rule.Save(indexName: test.indexName, rule: rule, forwardToReplicas: false, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .put,
          urlPath: "/1/indexes/testIndex/rules/testObjectID",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
              .init(name: "forwardToReplicas", value: "false")
          ],
          body: rule.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testGet() {
    let command = Command.Rule.Get(indexName: test.indexName, objectID: test.objectID, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/indexes/testIndex/rules/testObjectID",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testDelete() {
    let command = Command.Rule.Delete(indexName: test.indexName, objectID: test.objectID, forwardToReplicas: false, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .delete,
          urlPath: "/1/indexes/testIndex/rules/testObjectID",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
              .init(name: "forwardToReplicas", value: "false")
          ],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testSearch() {
    let query: RuleQuery = "testQuery"
    let command = Command.Rule.Search(indexName: test.indexName, query: query, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/testIndex/rules/search",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
          ],
          body: query.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testClear() {
    let command = Command.Rule.Clear(indexName: test.indexName, forwardToReplicas: false, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/indexes/testIndex/rules/clear",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
              .init(name: "forwardToReplicas", value: "false")
          ],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testSaveList() {
    let rules = [test.rule]
    let command = Command.Rule.SaveList(indexName: test.indexName, rules: rules, forwardToReplicas: true, clearExistingRules: true, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/indexes/testIndex/rules/batch",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
              .init(name: "forwardToReplicas", value: "true"),
              .init(name: "clearExistingRules", value: "true")
          ],
          body: rules.httpBody,
          requestOptions: test.requestOptions)
  }
  
  
}
