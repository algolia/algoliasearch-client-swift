//
//  SecuredAPIKeysIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SecuredAPIKeysIntegrationTests: OnlineTestCase {

  func testSecuredAPIKeys() throws {
    
    let index1 = client!.index(withName: "secured_api_keys")
    let index2 = client!.index(withName: "secured_api_keys_dev")
    let object: JSON = ["objectID": "one"]
    try index1.saveObject(object).wait()
    try index2.saveObject(object).wait()
    
    let restriction = SecuredAPIKeyRestriction()
      .set(\.validUntil, to: Date().addingTimeInterval(.minutes(10)).timeIntervalSince1970)
      .set(\.restrictIndices, to: [index1.name])
    
    let parentAPIKey = APIKey(rawValue: String(environmentVariable: "ALGOLIA_SEARCH_KEY_1")!)
    let generatedAPIKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    
    let newClient = SearchClient(appID: client.applicationID, apiKey: generatedAPIKey)
    
    let i1Results = try newClient.index(withName: index1.name).search(query: "")
    XCTAssertEqual(i1Results.hits.count, 1)
    
    try AssertThrowsHTTPError(try newClient.index(withName: index2.name).search(query: ""), statusCode: 403)

  }
  
  func testNotExpiredKey() throws {
    let restriction = SecuredAPIKeyRestriction().set(\.validUntil, to: Date().addingTimeInterval(.minutes(10)).timeIntervalSince1970)
    let parentAPIKey = APIKey(rawValue: .init(randomWithLength: 64))
    let generatedAPIKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    let remainingValidity = try XCTUnwrap(client.getSecuredApiKeyRemainingValidity(generatedAPIKey))
    XCTAssertGreaterThan(remainingValidity, 0)
  }
  
  func testExpiredKey() throws {
    let restriction = SecuredAPIKeyRestriction().set(\.validUntil, to: Date().addingTimeInterval(-.minutes(10)).timeIntervalSince1970)
    let parentAPIKey = APIKey(rawValue: .init(randomWithLength: 64))
    let generatedAPIKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    let remainingValidity = try XCTUnwrap(client.getSecuredApiKeyRemainingValidity(generatedAPIKey))
    XCTAssertLessThan(remainingValidity, 0)
  }
  
}
