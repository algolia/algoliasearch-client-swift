//
//  UserIDListResponse.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct UserIDListResponse: Codable {

  /// List of UserIDResponse found for a multi-cluster setup.
  public let userIDs: [UserIDResponse]

  /// Page which has been requested.
  public let page: Int

  /// Number of hits per page requested.
  public let hitsPerPage: Int

}
