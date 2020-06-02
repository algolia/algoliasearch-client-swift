//
//  SecuredAPIKeyRestrictionTests.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SecuredAPIKeyRestrictionTests: XCTestCase {
  
  func testQuery() {
    let query = Query()
      .set(\.query, to: "testQuery")
      .set(\.clickAnalytics, to: true)
    let validUntil = Date().addingTimeInterval(.minutes(10)).timeIntervalSince1970
    let restriction = SecuredAPIKeyRestriction(query: query,
                                               restrictIndices: ["index1", "index2"],
                                               restrictSources: ["127.0.0.1", "127.0.0.2"],
                                               validUntil: validUntil,
                                               userToken: "testUserToken")
    
    XCTAssertEqual(restriction.urlEncodedString, "query=testQuery&clickAnalytics=true&restrictIndices=index1,index2&restrictSources=127.0.0.1,127.0.0.2&userToken=testUserToken&validUntil=\(Int(validUntil))")
  }
  
}

class SecuredAPIKeyTests: XCTestCase {
  
  func testGenerate() {
    let parentAPIKey: APIKey = APIKey(rawValue: .init(randomWithLength: 64))
    let client = Client(appID: "testAppID", apiKey: "testAPIKey")
    let date = Date()
    let validity = date.addingTimeInterval(.minutes(10)).timeIntervalSince1970
    let restriction = SecuredAPIKeyRestriction()
      .set(\.restrictIndices, to: ["index1"])
      .set(\.userToken, to: "testUserToken")
      .set(\.validUntil, to: validity)
    let generatedAPIKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    sleep(5)
    let v = client.getSecuredApiKeyRemainingValidity(generatedAPIKey)!
    XCTAssertTrue(v > 0)
    XCTAssertTrue(v < TimeInterval(validity))
  }
  
}
