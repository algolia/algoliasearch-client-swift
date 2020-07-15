//
//  MultiClusterSnippets.swift
//  
//
//  Created by Vladislav Fitc on 01/07/2020.
//

import Foundation
import AlgoliaSearchClient

struct MultiClusterSnippets: SnippetsCollection {}

//MARK: - Assign or Move userID

extension MultiClusterSnippets {
  
  static var assignOrMoveUserID = """
  client.assignUser(
    withID #{userID}: __UserID__,
    toClusterWithName #{clusterName}: __ClusterName__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<Creation> -> Void__
  )
  """
  
  func assignOrMoveUserID() {
    client.assignUser(withID: "myUserID1", toClusterWithName: "c1-test") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Get top userID

extension MultiClusterSnippets {
  
  static var getTopUserID = """
  client.getTopUser(
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<TopUserIDResponse> -> Void__
  )
  """
  
  func getTopUserID() {
    client.getTopUser { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Get userID

extension MultiClusterSnippets {
  
  static var getUserID = """
  client.getUser(
    withID #{userID}: __UserID__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<UserIDResponse> -> Void__
  )
  """
  
  func getUserID() {
    client.getUser(withID: "myUserID1") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - List clusters

extension MultiClusterSnippets {
  
  static var listClusters = """
  client.listClusters(
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<ClustersListResponse> -> Void__
  )
  """
  
  func listClusters() {
    client.listClusters { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - List userIDs

extension MultiClusterSnippets {
  
  static var listUserIDs = """
  client.listUsers(
    #{page}: __Int?__ = nil,
    #{hitsPerPage}: __Int?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<UserIDListResponse> -> Void__
  )
  """
  
  func listUserIDs() {
    client.listUsers(page: 0, hitsPerPage: 20) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Remove userID

extension MultiClusterSnippets {
  
  static var removeUserID = """
  client.removeUser(
    withID #{userID}: __UserID__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<Deletion> -> Void__
  )
  """
  
  func removeUserID() {
    client.removeUser(withID: "myUserID1") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Search userID

extension MultiClusterSnippets {
  
  static var searchUserID = """
  client.searchUser(
    with query: __UserIDQuery__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<UserIDSearchResponse> -> Void__
  )

  struct UserIDQuery {
    var #{query}: __String?__
    var #{clusterName}: __ClusterName?__
    var #{page}: __Int?__
    var #{hitsPerPage}: __Int?__
  }
  """
  
  func searchUserID() {
    let query = UserIDQuery()
      .set(\.query, to: "query")
      .set(\.clusterName, to: "c1-test")
      .set(\.hitsPerPage, to: 12)
      .set(\.page, to: 0)
    
    client.searchUser(with: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Batch assign userIDs

extension MultiClusterSnippets {
  
  static var batchAssignUserIDs = """
  client.assignUsers(
    withIDs #{userIDs}: __[UserID]__,
    toClusterWithName #{clusterName}: __ClusterName__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<Creation> -> Void__
  )
  """
  
  func batchAssign() {
    client.assignUsers(withIDs: ["myUserID1", "myUserID2", "js"], toClusterWithName: "c1-test") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Has pending mappings

extension MultiClusterSnippets {
  
  static var hasPendingMappings = """
  client.hasPendingMappings(
    // All the following parameters are optional
    #{retrieveMappings}: Bool = false,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<HasPendingMappingResponse> -> Void__
  )
  """
  
  func hasPendingMappings() {
    client.hasPendingMappings(retrieveMappings: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}
