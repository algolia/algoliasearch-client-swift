//
//  MultiClusterIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

private extension SearchClient {
  
  func remove(_ userID: UserID) throws {
    while true {
      do {
        try removeUser(withID: userID)
        break
      } catch let error as HTTPError where error.statusCode == 400 || error.statusCode == 404 {
        continue
      } catch let error {
        throw error
      }
    }
  }
  
  func exists(_ userID: UserID) throws -> Bool {
    do {
      try getUser(withID: userID)
      return true
    } catch let error as HTTPError where error.statusCode == 404 {
      return false
    } catch let error {
      throw error
    }
  }
  
}

struct TestIdentifier {
  
  let rawValue: String
  
  init(date: Date = .init(), suffix: String? = nil) {
    let language = "swift"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD-HH-mm-ss"
    let dateString = dateFormatter.string(from: date)
    let username = NSUserName().description
    rawValue = [language, dateString, username, suffix].compactMap { $0 }.joined(separator: "-")
  }
  
}

class MultipleClusterIntegrationTests: OnlineTestCase {
  
  let date: Date = .init()
  
  override var allowFailure: Bool { return true }
  
  override var retryableTests: [() throws -> Void] {
    [multiCluster]
  }
  
  override var environment: TestCredentials.Environment { .mcm }
  
  func userID(_ id: String) -> UserID {
    return UserID(rawValue: TestIdentifier(date: date, suffix: id).rawValue)
  }
  
  func multiCluster() throws {
  
    let userID0 = userID("0")
    let userID1 = userID("1")
    let userID2 = userID("2")
    let userIDs = [userID0, userID1, userID2]
        
    let exists = client.exists
    let remove = client.remove
    
    let clusters = try client.listClusters().clusters
    
    XCTAssertEqual(clusters.count, 2)
    
    try client.assignUser(withID: userID0, toClusterWithName: clusters.first!.name)
    try client.assignUsers(withIDs: [userID1, userID2], toClusterWithName: clusters.first!.name)
        
    while try !(exists(userID0) && exists(userID1) && exists(userID2)) {
      sleep(1)
    }
    
    for userID in userIDs {
      let query = UserIDQuery().set(\.query, to: userID.rawValue)
      XCTAssertEqual(try client.searchUser(with: query).hits.count, 1)
    }
    
    XCTAssertFalse(try client.listUsers().userIDs.isEmpty)
    XCTAssertFalse(try client.getTopUser().topUsers.isEmpty)
    
    try remove(userID0)
    try remove(userID1)
    try remove(userID2)
            
    while try (exists(userID0) || exists(userID1) || exists(userID2)) {
      sleep(1)
    }

    try client.hasPendingMappings(retrieveMappings: true)
    
  }
  
}
