//
//  XCTest+HTTPError.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

@available(iOS 15.0.0, *)
func AssertThrowsHTTPError<T>(_ body: @autoclosure () async throws -> T, statusCode: Int, file: StaticString = #file, line: UInt = #line) async throws {
  do {
    let _ = try await body()
    XCTFail("Expected HTTP error", file: (file), line: line)
  } catch let error {
    guard let httpError = error as? HTTPError, httpError.statusCode == statusCode else {
      throw error
    }
  }
}
