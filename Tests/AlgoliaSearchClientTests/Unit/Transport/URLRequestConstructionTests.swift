//
//  URLRequestConstructionTests.swift
//
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class URLRequestConstructionTests: XCTestCase {
  func testConstruction() throws {
    let method = HTTPMethod.post
    let body: Data = "TestContent".data(using: .utf8)!
    let credentials = TestCredentials(applicationID: "testAppID", apiKey: "testApiKey")
    let request = URLRequest(
      command: Command.Custom(
        method: method, callType: .read, path: URL(string: "/my/test/path")!, body: body,
        requestOptions: nil)
    )
    .set(\.credentials, to: credentials)

    let expectedHeaders: [String: String] = [
      HTTPHeaderKey.applicationID.rawValue: credentials.applicationID.rawValue,
      HTTPHeaderKey.apiKey.rawValue: credentials.apiKey.rawValue,
    ]
    #if canImport(FoundationNetworking)
      XCTAssertEqual(
        request.allHTTPHeaderFields?.mapKeys { $0.lowercased() },
        expectedHeaders.mapKeys { $0.lowercased() })
    #else
      XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
    #endif
    XCTAssertEqual(request.httpMethod, method.rawValue)
    XCTAssertEqual(request.url?.absoluteString.starts(with: "https:/my/test/path"), true)
    XCTAssertEqual(request.httpBody, body)
  }

  func testStandartAPIKey() throws {
    let command = Command.Settings.SetSettings(
      indexName: "testIndex",
      settings: Settings(),
      resetToDefault: [],
      forwardToReplicas: nil,
      requestOptions: nil)
    var request = URLRequest(command: command)
    let rawAPIKey = "TEST_API_KEY"
    request.apiKey = APIKey(rawValue: rawAPIKey)
    XCTAssertEqual(request.allHTTPHeaderFields?[HTTPHeaderKey.apiKey.rawValue], rawAPIKey)
  }

  func testLongAPIKey() throws {
    let command = Command.Settings.SetSettings(
      indexName: "testIndex",
      settings: Settings(),
      resetToDefault: [],
      forwardToReplicas: nil,
      requestOptions: nil)
    var request = URLRequest(command: command)
    let rawAPIKey = String.random(length: URLRequest.maxHeaderAPIKeyLength + 1)
    request.apiKey = APIKey(rawValue: rawAPIKey)
    let json = try JSONDecoder().decode(JSON.self, from: request.httpBody!)
    XCTAssertNil(request.allHTTPHeaderFields?[HTTPHeaderKey.apiKey.rawValue])
    XCTAssertEqual(json["apiKey"], .string(rawAPIKey))
  }

  func testSwitchHost() throws {
    let timeout: TimeInterval = 10
    let request = URLRequest(
      command: Command.Custom(
        method: .post, callType: .write, path: URL(string: "/my/test/path")!, body: nil,
        requestOptions: nil))

    for index in 0...20 {
      var host = RetryableHost(url: URL(string: "test\(index).algolia.com")!)
      host.retryCount = index
      let requestWithHost = try request.switchingHost(by: host, withBaseTimeout: timeout)
      XCTAssertEqual(requestWithHost.timeoutInterval, timeout * TimeInterval(index + 1))
      XCTAssertEqual(
        requestWithHost.url?.absoluteString.starts(
          with: "https://test\(index).algolia.com/my/test/path"), true)
    }
  }

  func testPathPercentEncoding() {
    let command = Command.Indexing.GetObject(
      indexName: "myIndex",
      objectID: "gid://shopify/Collection/1122334455",
      attributesToRetrieve: [],
      requestOptions: nil)
    XCTAssertEqual(
      URLRequest(command: command).url?.absoluteString.starts(
        with: "https:/1/indexes/myIndex/gid:%2F%2Fshopify%2FCollection%2F1122334455"), true)
  }

  func testFiltersEncoding() {
    let query = Query("test")
      .set(\.filters, to: "\"manufacturer\":\"&Quirky\"")
    XCTAssertEqual(query.urlEncodedString, "query=test&filters=%22manufacturer%22:%22%26Quirky%22")
  }
}
