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
    let path = TestPath.path
    let body: Data = "TestContent".data(using: .utf8)!
    let credentials = TestCredentials(applicationID: "testAppID", apiKey: "testApiKey")

    let request = URLRequest(method: method,
                             path: path,
                             body: body).set(\.credentials, to: credentials)

    let expectedHeaders: [String: String] = [
      HTTPHeaderKey.applicationID.rawValue: credentials.applicationID.rawValue,
      HTTPHeaderKey.apiKey.rawValue: credentials.apiKey.rawValue
    ]
    #if canImport(FoundationNetworking)
    XCTAssertEqual(request.allHTTPHeaderFields?.mapKeys { $0.lowercased() }, expectedHeaders.mapKeys { $0.lowercased() })
    #else
    XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
    #endif
    XCTAssertEqual(request.httpMethod, method.rawValue)
    XCTAssertEqual(request.url?.absoluteString, "https:/my/test/path")
    XCTAssertEqual(request.httpBody, body)

  }

}
