//
//  APIKeysIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 22/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class APIKeysIntegrationTests: OnlineTestCase {
  
  override var indexNameSuffix: String? {
    return "apiKeys"
  }
  
  var keyToDelete: APIKey?
  
  override var retryableTests: [() throws -> Void] {
    [apiKeys]
  }

  
  func apiKeys() throws {
    
    let parameters = APIKeyParameters(ACLs: [.search])
      .set(\.description, to: "A description")
      .set(\.indices, to: ["index"])
      .set(\.maxHitsPerQuery, to: 1000)
      .set(\.maxQueriesPerIPPerHour, to: 1000)
      .set(\.query, to: Query().set(\.typoTolerance, to: .strict))
      .set(\.referers, to: ["referer"])
      .set(\.validity, to: 600)
    
    let addedKey = try client.addAPIKey(with: parameters)

    keyToDelete = addedKey.key
    
    var keyResponseContainer: APIKeyResponse? = nil
    
    for _ in 0...100 {
      do {
        keyResponseContainer = try client.getAPIKey(addedKey.key)
      } catch let error {
        if (error as? HTTPError)?.statusCode == 404 {
          continue
        } else {
          throw error
        }
      }
    }
    
    guard let addedKeyResponse = keyResponseContainer else {
      XCTFail("Key fetch failed")
      return
    }
    keyResponseContainer = nil
    
    XCTAssertEqual(addedKeyResponse.key, addedKey.key)
    XCTAssertEqual(addedKeyResponse.ACLs, [.search])
    XCTAssertEqual(addedKeyResponse.description, parameters.description)
    XCTAssertEqual(addedKeyResponse.indices, parameters.indices)
    XCTAssertEqual(addedKeyResponse.maxHitsPerQuery, parameters.maxHitsPerQuery)
    XCTAssertEqual(addedKeyResponse.maxQueriesPerIPPerHour, parameters.maxQueriesPerIPPerHour)
    XCTAssertEqual(addedKeyResponse.query, "typoTolerance=strict")
    XCTAssertEqual(addedKeyResponse.referers, ["referer"])
    XCTAssertLessThan(addedKeyResponse.validity, 600)
    XCTAssertGreaterThan(addedKeyResponse.validity, 500)

    let keysList = try client.listAPIKeys().keys
    XCTAssert(keysList.contains(where: { $0.key == addedKey.key }))
    
    try client.updateAPIKey(addedKey.key, with: APIKeyParameters(ACLs: []).set(\.maxHitsPerQuery, to: 42))
    
    for _ in 0...100 {
      keyResponseContainer = try client.getAPIKey(addedKey.key)
      if keyResponseContainer?.maxHitsPerQuery == 42 {
        break
      }
    }
    
    guard let updatedKeyResponse = keyResponseContainer else {
      XCTFail("Key update failed")
      return
    }
    keyResponseContainer = nil

    XCTAssertEqual(updatedKeyResponse.maxHitsPerQuery, 42)

    try client.deleteAPIKey(addedKey.key)
    
    for _ in 0...100 {
      keyResponseContainer = nil
      do {
        keyResponseContainer = try client.getAPIKey(addedKey.key)
      } catch let error {
        if (error as? HTTPError)?.statusCode == 404 {
          break
        } else {
          throw error
        }
      }
    }
    
    XCTAssertNil(keyResponseContainer)
    
    try client.restoreAPIKey(addedKey.key)
    
    for _ in 0...100 {
      do {
        keyResponseContainer = try client.getAPIKey(addedKey.key)
      } catch let error {
        if (error as? HTTPError)?.statusCode == 404 {
          continue
        } else {
          throw error
        }
      }
    }
    
    guard let restoredKeyResponse = keyResponseContainer else {
      XCTFail("Key restoration failed")
      return
    }
    keyResponseContainer = nil
    
    XCTAssertEqual(restoredKeyResponse.key, addedKey.key)

    
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    if let keyToDelete = keyToDelete {
      try client.deleteAPIKey(keyToDelete)
    }
  }
  
}
