//
//  XCTest+HTTPError.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

func AssertThrowsHTTPError<T>(_ body: @autoclosure () throws -> T, statusCode: Int, file: StaticString = #file, line: UInt = #line) throws {
  do {
    let _ = try body()
    XCTFail("Expected HTTP error", file: (file), line: line)
  } catch let error {
    guard case TransportError.httpError(let httpError) = error, httpError.statusCode == statusCode else {
      throw error
    }
//    guard let httpError = error as? HTTPError, httpError.statusCode == statusCode else {
//      throw error
//    }
  }
}
