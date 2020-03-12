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
  
  func testDecoding() {
    testDecoding(QueryType.prefixAll.rawValue, expected: "prefixAll")
    testDecoding(QueryType.prefixLast.rawValue, expected: "prefixLast")
    testDecoding(QueryType.prefixNone.rawValue, expected: "prefixNone")
  }
  
  func testEncoding() {
    testEncoding("prefixAll", expected: QueryType.prefixAll.rawValue)
    testEncoding("prefixLast", expected: QueryType.prefixLast.rawValue)
    testEncoding("prefixNone", expected: QueryType.prefixNone.rawValue)
  }
  
}
