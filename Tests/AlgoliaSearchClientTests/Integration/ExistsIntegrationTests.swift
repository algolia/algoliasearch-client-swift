//
//  ExistsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 22/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

@available(iOS 15.0.0, *)
class ExistsIntegrationTests: IntegrationTestCase {
  
  override var indexNameSuffix: String? {
    return "exists"
  }
  
  override var retryableAsyncTests: [() async throws -> Void] {
    [exists]
  }
  
  func exists() async throws {
    var exists = try await index.exists()
    XCTAssertFalse(exists)
    try await index.saveObject(TestRecord(), autoGeneratingObjectID: true).wait()
    exists = try await index.exists()
    XCTAssertTrue(exists)
    try await index.delete().wait()
    exists = try await index.exists()
    XCTAssertFalse(exists)
  }
  
}
