//
//  SecuredAPIKeysIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

@available(iOS 15.0.0, *)
class SecuredAPIKeysIntegrationTests: IntegrationTestCase {
  
  var parentAPIKey: APIKey!
  
  override var retryableAsyncTests: [() async throws -> Void] {
    [
      securedAPIKeys
    ]
  }
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    guard let rawParentAPIKey = String(environmentVariable: "ALGOLIA_SEARCH_KEY_1") else {
      let error = EnvironmentError.missingEnvironmentVariables(["ALGOLIA_SEARCH_KEY_1"])
      throw XCTSkip("\(error.description)")
    }
    parentAPIKey = .init(rawValue: rawParentAPIKey)
  }

  func securedAPIKeys() async throws {
    let index1 = client!.index(withName: "secured_api_keys")
    let index2 = client!.index(withName: "secured_api_keys_dev")
    let object: JSON = ["objectID": "one"]
    try await index1.saveObject(object).wait()
    try await index2.saveObject(object).wait()
    
    let restriction = SecuredAPIKeyRestriction()
      .set(\.validUntil, to: Date().addingTimeInterval(.minutes(10)).timeIntervalSince1970)
      .set(\.restrictIndices, to: [index1.name])
    
    let generatedAPIKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    
    let newClient = SearchClient(appID: client.applicationID, apiKey: generatedAPIKey)
    
    let i1Results = try await newClient.index(withName: index1.name).search(query: "")
    XCTAssertEqual(i1Results.hits.count, 1)
    
    try await AssertThrowsHTTPError(try await newClient.index(withName: index2.name).search(query: ""), statusCode: 403)

  }
  
  func testNotExpiredKey() async throws {
    let restriction = SecuredAPIKeyRestriction().set(\.validUntil, to: Date().addingTimeInterval(.minutes(10)).timeIntervalSince1970)
    let parentAPIKey = APIKey(rawValue: .init(randomWithLength: 64))
    let generatedAPIKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    let remainingValidity = try XCTUnwrap(client.getSecuredApiKeyRemainingValidity(generatedAPIKey))
    XCTAssertGreaterThan(remainingValidity, 0)
  }
  
  func testExpiredKey() async throws {
    let restriction = SecuredAPIKeyRestriction().set(\.validUntil, to: Date().addingTimeInterval(-.minutes(10)).timeIntervalSince1970)
    let parentAPIKey = APIKey(rawValue: .init(randomWithLength: 64))
    let generatedAPIKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    let remainingValidity = try XCTUnwrap(client.getSecuredApiKeyRemainingValidity(generatedAPIKey))
    XCTAssertLessThan(remainingValidity, 0)
  }
  
}
