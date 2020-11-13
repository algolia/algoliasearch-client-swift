//
//  File.swift
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

struct TestCredentials: Credentials {

  let applicationID: ApplicationID
  let apiKey: APIKey

  static let environment: TestCredentials? = {
    if
      let appID = String(environmentVariable: "ALGOLIA_APPLICATION_ID_1"),
      let apiKey = String(environmentVariable: "ALGOLIA_ADMIN_KEY_1") {
      return TestCredentials(applicationID: ApplicationID(rawValue: appID), apiKey: APIKey(rawValue: apiKey))
    } else {
      return nil
    }
  }()

  static let places: TestCredentials? = {
    if
      let appID = String(environmentVariable: "ALGOLIA_PLACES_APPLICATION_ID"),
      let apiKey = String(environmentVariable: "ALGOLIA_PLACES_API_KEY") {
      return TestCredentials(applicationID: ApplicationID(rawValue: appID), apiKey: APIKey(rawValue: apiKey))
    } else {
      return nil
    }
  }()
  
  static let mcm: TestCredentials? = {
    if
      let appID = String(environmentVariable: "ALGOLIA_APPLICATION_ID_MCM"),
      let apiKey = String(environmentVariable: "ALGOLIA_ADMIN_KEY_MCM") {
      return TestCredentials(applicationID: ApplicationID(rawValue: appID), apiKey: APIKey(rawValue: apiKey))
    } else {
      return nil
    }
  }()

}

struct TestPath {
  static var path: TestPathLevel2 = TestPathRoot() >>> TestPathLevel1() >>> TestPathLevel2()
}

struct TestPathRoot: RootPath {

  var rawValue: String = "/my"

}

struct TestPathLevel1: PathComponent {

  var parent: TestPathRoot?

  var rawValue: String = "test"

}

struct TestPathLevel2: PathComponent {

  var parent: TestPathLevel1?

  var rawValue: String = "path"

}

class URLRequestBuilding: XCTestCase {

  func testBuilding() throws {

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
