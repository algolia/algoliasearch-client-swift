//
//  ExistsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 22/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class ExistsIntegrationTests: OnlineTestCase {
  
  override var indexNameSuffix: String? {
    return "exists"
  }
  
  func testExists() throws {
    XCTAssertFalse(try index.exists())
    try index.saveObject(TestRecord()).wait()
    XCTAssertTrue(try index.exists())
    try index.delete().wait()
    XCTAssertFalse(try index.exists())
  }
  
}
