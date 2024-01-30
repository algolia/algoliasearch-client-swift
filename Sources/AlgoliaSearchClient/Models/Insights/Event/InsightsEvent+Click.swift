//
//  InsightsEvent+Click.swift
//
//
//  Created by Vladislav Fitc on 23/04/2020.
//

import Foundation

extension InsightsEvent {
  public static func click(
    name: EventName,
    indexName: IndexName,
    userToken: UserToken?,
    timestamp: Date? = nil,
    queryID: QueryID,
    objectIDsWithPositions: [(ObjectID, Int)]
  ) throws -> Self {
    try self.init(
      type: .click,
      name: name,
      indexName: indexName,
      userToken: userToken,
      timestamp: timestamp,
      queryID: queryID,
      resources: .objectIDsWithPositions(objectIDsWithPositions))
  }

  public static func click(
    name: EventName,
    indexName: IndexName,
    userToken: UserToken?,
    timestamp: Date? = nil,
    objectIDs: [ObjectID]
  ) throws -> Self {
    try self.init(
      type: .click,
      name: name,
      indexName: indexName,
      userToken: userToken,
      timestamp: timestamp,
      queryID: .none,
      resources: .objectIDs(objectIDs))
  }

  public static func click(
    name: EventName,
    indexName: IndexName,
    userToken: UserToken?,
    timestamp: Date? = nil,
    filters: [String]
  ) throws -> Self {
    try self.init(
      type: .click,
      name: name,
      indexName: indexName,
      userToken: userToken,
      timestamp: timestamp,
      queryID: .none,
      resources: .filters(filters))
  }
}
