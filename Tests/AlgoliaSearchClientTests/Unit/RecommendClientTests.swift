//
//  RecommendClientTests.swift
//  
//
//  Created by Vladislav Fitc on 01/09/2021.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class RecommendClientTests: XCTestCase {
  
  func testRecommendations() {
    let requester = TestRequester()
    let client = RecommendClient(configuration: .init(applicationID: "test-app-id", apiKey: "test-api-key"), requester: requester)
    
    let exp = expectation(description: "request")
    
    requester.onRequest = { request in
      XCTAssertEqual(request.url?.absoluteString.starts(with: "https://test-app-id-dsn.algolia.net/1/indexes/*/recommendations?"), true)
      XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
      XCTAssertEqual(request.value(forHTTPHeaderField: "X-Algolia-Application-Id"), "test-app-id")
      XCTAssertEqual(request.value(forHTTPHeaderField: "X-Algolia-Api-Key"), "test-api-key")
      XCTAssertEqual(request.httpMethod, "POST")
      XCTAssertNotNil(request.httpBody)
      if let body = request.httpBody {
        AssertMatch(body, ["requests": [
          [
            "model" : "bought-together",
            "objectID" : "B018APC4LE",
            "indexName" : "IndexName",
            "threshold" : 0,
          ]]
        ])
      }
      exp.fulfill()
    }
    
    client.getRecommendations(options: [.init(indexName: "IndexName",
                                              model: .boughtTogether,
                                              objectID: "B018APC4LE")]) { _ in }
    
    waitForExpectations(timeout: 5, handler: nil)

  }
  
  func testFrequentlyBoughtTogether() {
    
    let requester = TestRequester()
    let client = RecommendClient(configuration: .init(applicationID: "test-app-id", apiKey: "test-api-key"), requester: requester)
    
    let exp = expectation(description: "request")
    
    requester.onRequest = { request in
      XCTAssertEqual(request.url?.absoluteString.starts(with: "https://test-app-id-dsn.algolia.net/1/indexes/*/recommendations?"), true)
      XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
      XCTAssertEqual(request.value(forHTTPHeaderField: "X-Algolia-Application-Id"), "test-app-id")
      XCTAssertEqual(request.value(forHTTPHeaderField: "X-Algolia-Api-Key"), "test-api-key")
      XCTAssertEqual(request.httpMethod, "POST")
      XCTAssertNotNil(request.httpBody)
      if let body = request.httpBody {
        AssertMatch(body, ["requests": [
          [
            "model" : "bought-together",
            "objectID" : "B018APC4LE",
            "indexName" : "IndexName",
            "threshold" : 0,
          ]]
        ])
      }
      exp.fulfill()
    }
    
    client.getFrequentlyBoughtTogether(options: [.init(indexName: "IndexName", objectID: "B018APC4LE")]) { _ in }
    
    waitForExpectations(timeout: 5, handler: nil)
    
  }
  
  func testRelatedProducts() {
    
    let requester = TestRequester()
    let client = RecommendClient(configuration: .init(applicationID: "test-app-id", apiKey: "test-api-key"), requester: requester)
    
    let exp = expectation(description: "request")
    
    requester.onRequest = { request in
      XCTAssertEqual(request.url?.absoluteString.starts(with: "https://test-app-id-dsn.algolia.net/1/indexes/*/recommendations?"), true)
      XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
      XCTAssertEqual(request.value(forHTTPHeaderField: "X-Algolia-Application-Id"), "test-app-id")
      XCTAssertEqual(request.value(forHTTPHeaderField: "X-Algolia-Api-Key"), "test-api-key")
      XCTAssertEqual(request.httpMethod, "POST")
      XCTAssertNotNil(request.httpBody)
      if let body = request.httpBody {
        AssertMatch(body, ["requests": [
          [
            "model" : "related-products",
            "objectID" : "B018APC4LE",
            "indexName" : "IndexName",
            "threshold" : 0,
          ]]
        ])
      }
      exp.fulfill()
    }
    
    client.getRelatedProducts(options: [.init(indexName: "IndexName", objectID: "B018APC4LE")]) { _ in }
    
    waitForExpectations(timeout: 5, handler: nil)
    
  }

  
}
