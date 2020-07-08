//
//  AlgoliaCommandTest.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

protocol AlgoliaCommandTest {

  var test: TestValues { get }
  func check(command: AlgoliaCommand, callType: CallType, method: HTTPMethod, urlPath: String, queryItems: Set<URLQueryItem>, body: Data?, additionalHeaders: [HTTPHeaderKey: String]?, requestOptions: RequestOptions, file: StaticString, line: UInt)

}

extension AlgoliaCommandTest {

  var test: TestValues {
    return TestValues()
  }

  func check(command: AlgoliaCommand, callType: CallType, method: HTTPMethod, urlPath: String, queryItems: Set<URLQueryItem>, body: Data?, additionalHeaders: [HTTPHeaderKey: String]? = nil, requestOptions: RequestOptions, file: StaticString = #file, line: UInt = #line) {
    let request = command.urlRequest
    XCTAssertEqual(command.callType, callType, file: file, line: line)
    XCTAssertEqual(request.httpMethod, method.rawValue, file: file, line: line)
    XCTAssertEqual(request.allHTTPHeaderFields, requestOptions.headers.merging(additionalHeaders ?? [:]).mapKeys { $0.rawValue }, file: file, line: line)
    let comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
    XCTAssertEqual(request.url?.path, urlPath, file: file, line: line)
    XCTAssertEqual(comps.queryItems.flatMap(Set.init), queryItems, file: file, line: line)
    XCTAssertEqual(request.httpBody, body, file: file, line: line)
  }

}
