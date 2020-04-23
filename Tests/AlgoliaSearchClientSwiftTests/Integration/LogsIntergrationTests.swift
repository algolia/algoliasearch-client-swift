//
//  LogsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 06/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class LogsIntergrationTests: OnlineTestCase {
  
  override var indexNameSuffix: String? {
    "logs"
  }

  func testGetLogs() throws {
    try client.listIndices()
    try client.listIndices()
    let logs = try client.getLogs(page: 0, hitsPerPage: 2, type: .all)
    XCTAssertEqual(logs.count, 2)
  }

}
