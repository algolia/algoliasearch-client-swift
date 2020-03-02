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

}

class URLRequestBuilding: XCTestCase {
  
  func testBuilding() {
    
    let method = HttpMethod.POST
    let path = "/my/test/path"
    let callType = CallType.read
    let body: Data = "TestContent".data(using: .utf8)!
    let credentials = TestCredentials(applicationID: "testAppID", apiKey: "testApiKey")
    
    let request = URLRequest(method: method,
                             path: path,
                             callType: callType,
                             body: body,
                             credentials: credentials,
                             configuration: SearchConfigration.default)
    
    let expectedHeaders: [String: String] = [
      HTTPHeaderKey.applicationID.rawValue: credentials.applicationID.rawValue,
      HTTPHeaderKey.apiKey.rawValue: credentials.apiKey.rawValue
    ]
    XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
    XCTAssertEqual(request.httpMethod, method.rawValue)
    XCTAssertEqual(request.url?.absoluteString, "https:/my/test/path")
    XCTAssertEqual(request.httpBody, body)
    

        
  }
  
  func testWithHostConstructor() {
    
    let method = HttpMethod.POST
    let path = "/my/test/path"
    let callType = CallType.read

    let request = URLRequest(method: method,
                             path: path,
                             callType: callType,
                             configuration: SearchConfigration.default)
    
    for index in 0...2 {
      let host = RetryableHost(url: URL(string: "test\(index).algolia.com")!)
      let requestWithHost = request.withHost(host)
      XCTAssertEqual(requestWithHost.url?.absoluteString, "https://test\(index).algolia.com/my/test/path")
    }
    
  }
  
}
