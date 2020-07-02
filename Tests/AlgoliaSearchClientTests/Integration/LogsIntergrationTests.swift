//
//  LogsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 06/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class LogsIntergrationTests: OnlineTestCase {
  
  override var indexNameSuffix: String? {
    "logs"
  }

  func testGetLogs() throws {
    try client.listIndices()
    try client.listIndices()
    let logs = try client.getLogs(offset: 0, length: 2, type: .all).logs
    XCTAssertEqual(logs.count, 2)
  }

}
