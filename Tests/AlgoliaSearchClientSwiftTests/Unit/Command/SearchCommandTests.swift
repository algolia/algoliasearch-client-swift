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
  
}
