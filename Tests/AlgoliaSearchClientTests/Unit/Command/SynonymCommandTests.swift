//
//  SynonymCommandTests.swift
//  
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class SynonymCommandTests: XCTestCase, AlgoliaCommandTest {

  func testSave() {
    let synonym = test.synonym
    let command = Command.Synonym.Save(indexName: test.indexName, synonym: synonym, forwardToReplicas: false, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .put,
          urlPath: "/1/indexes/testIndex/synonyms/testObjectID",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
              .init(name: "forwardToReplicas", value: "false")
          ],
          body: synonym.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testGet() {
    let command = Command.Synonym.Get(indexName: test.indexName, objectID: test.objectID, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/indexes/testIndex/synonyms/testObjectID",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testDelete() {
    let command = Command.Synonym.Delete(indexName: test.indexName, objectID: test.objectID, forwardToReplicas: false, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .delete,
          urlPath: "/1/indexes/testIndex/synonyms/testObjectID",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
              .init(name: "forwardToReplicas", value: "false")
          ],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testSearch() {
    let query: SynonymQuery = "testQuery"
    let command = Command.Synonym.Search(indexName: test.indexName, query: query, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/testIndex/synonyms/search",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
          ],
          body: query.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testClear() {
    let command = Command.Synonym.Clear(indexName: test.indexName, forwardToReplicas: false, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/indexes/testIndex/synonyms/clear",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
              .init(name: "forwardToReplicas", value: "false")
          ],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testSaveList() {
    let synonyms = [test.synonym]
    let command = Command.Synonym.SaveList(indexName: test.indexName, synonyms: synonyms, forwardToReplicas: true, clearExistingSynonyms: true, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/indexes/testIndex/synonyms/batch",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
              .init(name: "forwardToReplicas", value: "true"),
              .init(name: "replaceExistingSynonyms", value: "true")
          ],
          body: synonyms.httpBody,
          requestOptions: test.requestOptions)
  }
  
  
}
