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

  enum CodingKeys: String, CodingKey {
    case topUsers
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rawTopUsers: [String: [UserIDResponse]] = try container.decode(forKey: .topUsers)
    let keyValuePairs = rawTopUsers.map { (ClusterName(rawValue: $0), $1) }
    self.topUsers = Dictionary(uniqueKeysWithValues: keyValuePairs)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let keyValuePairs = topUsers.map { ($0.rawValue, $1) }
    let rawTopUsers = Dictionary(uniqueKeysWithValues: keyValuePairs)
    try container.encode(rawTopUsers, forKey: .topUsers)
  }

}
