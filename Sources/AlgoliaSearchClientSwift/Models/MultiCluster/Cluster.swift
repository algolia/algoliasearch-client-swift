//
//  Cluster.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct Cluster: Codable {
  
  /// Name of the cluster.
  let name: ClusterName
  
  /// Number of records in the cluster.
  let nbRecords: Int
  
  /// Number of users assigned to the cluster.
  let nbUserIDs: Int
  
  /// Data size taken by all the users assigned to the cluster.
  let dataSize: Int
  
}
