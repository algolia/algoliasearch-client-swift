//
//  ExistsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 22/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class ExistsIntegrationTests: IntegrationTestCase {
  
  override var indexNameSuffix: String? {
    return "exists"
  }
  
  override var retryableTests: [() throws -> Void] {
    [exists]
  }
  
  func exists() throws {
    XCTAssertFalse(try index.exists())
    try index.saveObject(TestRecord(), autoGeneratingObjectID: true).wait()
    XCTAssertTrue(try index.exists())
    try index.delete().wait()
    XCTAssertFalse(try index.exists())
  }
  
}
