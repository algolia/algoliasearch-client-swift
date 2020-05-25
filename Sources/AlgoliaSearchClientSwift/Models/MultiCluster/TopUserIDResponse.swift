//
//  TopUserIDResponse.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct TopUserIDResponse: Codable {
  
  /// Mapping of ClusterName to top users.
  public let topUsers: [ClusterName: [UserIDResponse]]
  
}
