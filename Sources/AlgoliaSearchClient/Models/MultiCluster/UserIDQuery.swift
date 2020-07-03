//
//  UserIDQuery.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

/// Query to use with Client.searchUserID.
public struct UserIDQuery: Codable {

  /// Query to search. The search is a prefix search with typoTolerance. Use empty query to retrieve all users.
  /// - Engine default: ""
  public var query: String?

  /// Engine default: null
  /// If specified only clusters assigned to this cluster can be returned.
  public var clusterName: ClusterName?

  /// Engine default: 0
  /// Page to fetch.
  public var page: Int?

  /// Engine default: 20
  /// Number of users to return by page.
  public var hitsPerPage: Int?

  public init(query: String? = nil,
              clusterName: ClusterName? = nil,
              page: Int? = nil,
              hitsPerPage: Int? = nil) {
    self.query = query
    self.clusterName = clusterName
    self.clusterName = clusterName
    self.page = page
    self.hitsPerPage = hitsPerPage
  }

}

extension UserIDQuery: Builder {}

extension UserIDQuery: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.query = value
  }

}
