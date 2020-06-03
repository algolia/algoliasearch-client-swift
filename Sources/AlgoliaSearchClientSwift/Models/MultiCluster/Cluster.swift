//
//  Cluster.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct Cluster: Codable {

  /// Name of the cluster.
  public let name: ClusterName

  /// Number of records in the cluster.
  public let nbRecords: Int

  /// Number of users assigned to the cluster.
  public let nbUserIDs: Int

  /// Data size taken by all the users assigned to the cluster.
  public let dataSize: Int

  enum CodingKeys: String, CodingKey {
    case name = "clusterName"
    case nbRecords
    case nbUserIDs
    case dataSize
  }

}
