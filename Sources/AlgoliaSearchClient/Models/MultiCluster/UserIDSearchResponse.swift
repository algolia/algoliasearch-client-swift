//
//  UserIDSearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct UserIDSearchResponse: Codable {

  /// List of UserIDResponse matching the query.
  public let hits: [UserIDResponse]

  /// Number of userIDs matching the query.
  public let nbHits: Int

  /// Current page.
  public let page: Int

  /// Number of hits retrieved per page.
  public let hitsPerPage: Int

  /// Timestamp of the last update of the index
  public let updatedAt: Date

}
