//
//  CustomClientConfigurationTests.swift
//
//
//  Created by Vladislav Fitc on 27/11/2023.
//

import Foundation

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class CustomClientConfigurationTests: XCTestCase {

  func testCustomHeaders() throws {
    let configuration = SearchConfiguration(applicationID: "undefined", apiKey: "undefined")
      .set(\.defaultHeaders, to: ["default-header": "default-header-value"])

    let requester = TestRequester()
    
    let client = SearchClient(configuration: configuration,
                              requester: requester)
    
    let exp = expectation(description: "method call")
    
    requester.onRequest = { request in
      let headers = request.allHTTPHeaderFields ?? [:]
      XCTAssert(headers.contains(where: { $0.key == "default-header" && $0.value == "default-header-value" }))
      XCTAssert((request.allHTTPHeaderFields ?? [:]).contains(where: { $0.key == "another-header" && $0.value == "another-value" }))
      exp.fulfill()
    }
    
    let queries: [MultiSearchQuery] = [
      .hitsSearch(.init(indexName: "some-index", query: "search"))
    ]
    
    let requestOptions = RequestOptions(headers: ["another-header": "another-value"])
    
    client.search(queries: queries, requestOptions: requestOptions) { _ in }
    
    waitForExpectations(timeout: 5)

  }

}
