//
//  XCTest+HTTPError.swift
//
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

func AssertThrowsHTTPError(
  _ body: @autoclosure () throws -> some Any, statusCode: Int, file: StaticString = #file,
  line: UInt = #line
) throws {
  do {
    _ = try body()
    XCTFail("Expected HTTP error", file: file, line: line)
  } catch {
    guard case let TransportError.httpError(httpError) = error, httpError.statusCode == statusCode
    else {
      throw error
    }
    //    guard let httpError = error as? HTTPError, httpError.statusCode == statusCode else {
    //      throw error
    //    }
  }
}
