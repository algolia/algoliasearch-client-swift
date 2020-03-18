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
    
    let method = HttpMethod.post
    let path = "/my/test/path"
    let body: Data = "TestContent".data(using: .utf8)!
    let credentials = TestCredentials(applicationID: "testAppID", apiKey: "testApiKey")
    
    var request = URLRequest(method: method,
                             path: path,
                             body: body)
    request.set(credentials)
    
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
    
    let method = HttpMethod.post
    let path = "/my/test/path"
    let baseTimeout: TimeInterval = 10

    let request = URLRequest(method: method,
                             path: path)
    
    var requestOptions = RequestOptions()
    requestOptions.readTimeout = baseTimeout
    
    for index in 0...2 {
      var host = RetryableHost(url: URL(string: "test\(index).algolia.com")!)
      host.retryCount = index
      let requestWithHost = request.withHost(host, requestOptions: requestOptions)
      XCTAssertEqual(requestWithHost.timeoutInterval, baseTimeout * TimeInterval(index + 1))
      XCTAssertEqual(requestWithHost.url?.absoluteString, "https://test\(index).algolia.com/my/test/path")
    }
    
  }

  
}
