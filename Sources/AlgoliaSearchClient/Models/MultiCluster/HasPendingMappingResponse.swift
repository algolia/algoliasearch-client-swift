//
//  HasPendingMappingResponse.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct HasPendingMappingResponse: Codable {

  public let isPending: Bool
  public let clusters: [ClusterName: [UserID]]?

  enum CodingKeys: String, CodingKey {
    case isPending = "pending"
    case clusters
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let rawClusters: [String: [UserID]] = try container.decodeIfPresent(forKey: .clusters) {
      let keyValuePairs = rawClusters.map { (ClusterName(rawValue: $0), $1) }
      self.clusters = Dictionary(uniqueKeysWithValues: keyValuePairs)
    } else {
      self.clusters = nil
    }
    self.isPending = try container.decode(forKey: .isPending)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let keyValuePairs = clusters?.compactMap { ($0.rawValue, $1) }
    let rawClusters = keyValuePairs.flatMap(Dictionary.init(uniqueKeysWithValues:))
    try container.encodeIfPresent(rawClusters, forKey: .clusters)
    try container.encode(isPending, forKey: .isPending)
  }

}
