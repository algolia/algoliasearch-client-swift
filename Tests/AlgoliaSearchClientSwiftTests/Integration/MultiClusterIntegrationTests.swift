//
//  MultiClusterIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

private extension Client {
  
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

class MultipleClusterIntegrationTests: OnlineTestCase {
  
  let date: Date = .init()
  
  func userID(_ id: String) -> UserID {
    let lang = "swift"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD-HH-mm-ss"
    let dateString = dateFormatter.string(from: date)
    return UserID(rawValue: [lang, dateString, NSUserName().description, id].joined(separator: "-"))
  }
    
  func testMultiCluster() throws {
  
    let userID0 = userID("0")
    let userID1 = userID("1")
    let userID2 = userID("2")
    let userIDs = [userID0, userID1, userID2]
    
    let client = Client(appID: TestCredentials.mcm!.applicationID, apiKey: TestCredentials.mcm!.apiKey)
    
    let exists = client.exists
    let remove = client.remove
    
    let clusters = try client.listClusters().clusters
    
    XCTAssertEqual(clusters.count, 2)
    
    try client.assignUser(withID: userID0, to: clusters.first!.name)
    try client.assignUsers(withIDs: [userID1, userID2], to: clusters.first!.name)
        
    while try !(exists(userID0) && exists(userID1) && exists(userID2)) {
      sleep(1)
    }
    
    for userID in userIDs {
      let query = UserIDQuery().set(\.query, to: userID.rawValue)
      XCTAssertEqual(try client.searchUser(query: query).hits.count, 1)
    }
    
    XCTAssertFalse(try client.listUsers().userIDs.isEmpty)
    XCTAssertFalse(try client.getTopUser().topUsers.isEmpty)
    
    try remove(userID0)
    try remove(userID1)
    try remove(userID2)
            
    while try (exists(userID0) || exists(userID1) || exists(userID2)) {
      sleep(1)
    }

    try client.hasPendingMapping(retrieveMapping: true)
    
  }
  
}
