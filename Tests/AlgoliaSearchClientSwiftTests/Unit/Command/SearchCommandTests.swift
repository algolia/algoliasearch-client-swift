//
//  SearchCommandTests.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SearchCommandTests: XCTestCase, AlgoliaCommandTest {
  
  func testSearch() {
    let command = Command.Search.Search(indexName: test.indexName, query: test.query, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/testIndex/query",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: test.query.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testBrowseQuery() {
    let command = Command.Search.Browse(indexName: test.indexName, query: test.query, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/testIndex/browse",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: test.query.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testBrowseCursor() {
    let command = Command.Search.Browse(indexName: test.indexName, cursor: test.cursor, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/indexes/testIndex/browse",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testSearchForFacets() {
    let command = Command.Search.SearchForFacets(indexName: test.indexName,
                                                 attribute: test.attribute,
                                                 facetQuery: "test facet query",
                                                 query: nil,
                                                 requestOptions: test.requestOptions)
    let body = FieldWrapper<JSON>(params: ["facetQuery": "test facet query"]).httpBody
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/testIndex/facets/testAttribute/query",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: body,
          requestOptions: test.requestOptions)
  }
  
  func testSearchForFacetsWithQuery() {
    let command = Command.Search.SearchForFacets(indexName: test.indexName,
                                                 attribute: test.attribute,
                                                 facetQuery: "test facet query",
                                                 query: test.query,
                                                 requestOptions: test.requestOptions)
    let query = test.query.set(\.customParameters, to: [
      "customKey": "customValue",
      "facetQuery": "test facet query"])
    let body = FieldWrapper(params: query).httpBody
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/testIndex/facets/testAttribute/query",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: body,
          requestOptions: test.requestOptions)
  }
  
}
