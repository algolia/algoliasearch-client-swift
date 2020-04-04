//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

struct TestCredentials: Credentials {

  let applicationID: ApplicationID
  let apiKey: APIKey

  static let environment: TestCredentials? = {
    if
      let appID = String(environmentVariable: "ALGOLIA_APPLICATION_ID"),
      let apiKey = String(environmentVariable: "ALGOLIA_API_KEY") {
      return TestCredentials(applicationID: ApplicationID(rawValue: appID), apiKey: APIKey(rawValue: apiKey))
    } else {
      return nil
    }
  }()

}

class URLRequestBuilding: XCTestCase {

  func testBuilding() {

    let method = HttpMethod.post
    let path = "/my/test/path"
    let body: Data = "TestContent".data(using: .utf8)!
    let credentials = TestCredentials(applicationID: "testAppID", apiKey: "testApiKey")

    let request = URLRequest(method: method,
                             path: path,
                             body: body).set(\.credentials, to: credentials)

    let expectedHeaders: [String: String] = [
      HTTPHeaderKey.applicationID.rawValue: credentials.applicationID.rawValue,
      HTTPHeaderKey.apiKey.rawValue: credentials.apiKey.rawValue
    ]
    XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
    XCTAssertEqual(request.httpMethod, method.rawValue)
    XCTAssertEqual(request.url?.absoluteString, "https:/my/test/path")
    XCTAssertEqual(request.httpBody, body)

  }


}
