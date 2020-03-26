//
//  AlgoliaCommandTest.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

protocol AlgoliaCommandTest {
  
  var test: TestValues { get }
  func check(command: AlgoliaCommand, callType: CallType, method: HttpMethod, urlPath: String, queryItems: Set<URLQueryItem>, body: Data?, requestOptions: RequestOptions)

}

extension AlgoliaCommandTest {
  
  var test: TestValues {
    return TestValues()
  }

  func check(command: AlgoliaCommand, callType: CallType, method: HttpMethod, urlPath: String, queryItems: Set<URLQueryItem>, body: Data?, requestOptions: RequestOptions) {
    let request = command.urlRequest
    XCTAssertEqual(command.callType, callType)
    XCTAssertEqual(request.httpMethod, method.rawValue)
    XCTAssertEqual(request.allHTTPHeaderFields, requestOptions.headers)
    let comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
    XCTAssertEqual(request.url?.path, urlPath)
    XCTAssertEqual(comps.queryItems.flatMap(Set.init), queryItems)
    XCTAssertEqual(request.httpBody, body)
  }
  
}

