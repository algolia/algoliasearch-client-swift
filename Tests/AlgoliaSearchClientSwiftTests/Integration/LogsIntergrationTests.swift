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
  
  func testGetLogs() throws {
    _ = try index.getLogs(page: 0, hitsPerPage: 5000, logType: .all)
  }
  
}
