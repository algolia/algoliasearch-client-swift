//
//  QueryTypeTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class QueryTypeTests: XCTestCase {

  func testDecoding() throws {
    try testDecoding(QueryType.prefixAll.rawValue, expected: "prefixAll")
    try testDecoding(QueryType.prefixLast.rawValue, expected: "prefixLast")
    try testDecoding(QueryType.prefixNone.rawValue, expected: "prefixNone")
  }

  func testEncoding() throws {
    try testEncoding("prefixAll", expected: QueryType.prefixAll.rawValue)
    try testEncoding("prefixLast", expected: QueryType.prefixLast.rawValue)
    try testEncoding("prefixNone", expected: QueryType.prefixNone.rawValue)
  }

}
