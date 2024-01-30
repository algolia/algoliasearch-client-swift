//
//  QueryTypeTests.swift
//
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class QueryTypeTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(QueryType.prefixAll, "prefixAll")
    try AssertEncodeDecode(QueryType.prefixLast, "prefixLast")
    try AssertEncodeDecode(QueryType.prefixNone, "prefixNone")
  }
}
