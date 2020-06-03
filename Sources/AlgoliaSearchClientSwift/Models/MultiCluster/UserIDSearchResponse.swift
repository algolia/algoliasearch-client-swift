//
//  UserIDSearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct UserIDSearchResponse: Codable {

  /// List of UserIDResponse matching the query.
  let hits: [UserIDResponse]

  /// Number of userIDs matching the query.
  let nbHits: Int

  /// Current page.
  let page: Int

  /// Number of hits retrieved per page.
  let hitsPerPage: Int

  /// Timestamp of the last update of the index
  let updatedAt: Date

}
