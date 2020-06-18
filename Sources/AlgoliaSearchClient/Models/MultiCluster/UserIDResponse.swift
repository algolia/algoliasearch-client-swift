//
//  UserIDResponse.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct UserIDResponse {

  /// UserID of the user.
  public let userID: UserID

  /// Number of records belonging to the user.
  public let nbRecords: Int

  /// Data size used by the user.
  public let dataSize: Int

  /// Cluster on which the data of the user is stored.
  public let clusterName: ClusterName?

  /// ObjectID of the requested user. Same as UserID.
  public let objectID: ObjectID?

  /// Highlighted attributes.
  public let highlightResult: TreeModel<HighlightResult>?

}

extension UserIDResponse: Codable {

  enum CodingKeys: String, CodingKey {
    case userID
    case nbRecords
    case dataSize
    case clusterName
    case objectID
    case highlightResult = "_highlightResult"
  }

}
