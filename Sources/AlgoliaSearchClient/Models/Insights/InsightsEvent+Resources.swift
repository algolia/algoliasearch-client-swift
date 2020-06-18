//
//  InsightsEvent+Resources.swift
//  
//
//  Created by Vladislav Fitc on 23/04/2020.
//

import Foundation

extension InsightsEvent {

  public enum Resources: Equatable {
    case objectIDs([ObjectID])
    case filters([String])
    case objectIDsWithPositions([(ObjectID, Int)])

    public static func == (lhs: InsightsEvent.Resources, rhs: InsightsEvent.Resources) -> Bool {
      switch (lhs, rhs) {
      case (.objectIDs(let lValue), .objectIDs(let rValue)):
        return lValue == rValue
      case (.filters(let lValue), .filters(let rValue)):
        return lValue == rValue
      case (.objectIDsWithPositions(let lValue), .objectIDsWithPositions(let rValue)):
        return lValue.map { $0.0 } == rValue.map { $0.0 } && lValue.map { $0.1 } == rValue.map { $0.1 }
      default:
        return false
      }
    }

  }

}

extension InsightsEvent.Resources: Codable {

  enum CodingKeys: String, CodingKey {
    case objectIDs
    case filters
    case positions
  }

  public init(from decoder: Decoder) throws {

    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let objectIDs = try? container.decode([ObjectID].self, forKey: .objectIDs) {
      if let positions = try? container.decode([Int].self, forKey: .positions) {
        self = .objectIDsWithPositions(zip(objectIDs, positions).map { $0 })
      } else {
        self = .objectIDs(objectIDs)
      }
    } else if let filters = try? container.decode([String].self, forKey: .filters) {
      self = .filters(filters)
    } else {
      throw Error.decodingFailure
    }

  }

  public func encode(to encoder: Encoder) throws {

    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .filters(let filters):
      try container.encode(filters, forKey: .filters)

    case .objectIDsWithPositions(let objectIDswithPositions):
      try container.encode(objectIDswithPositions.map { $0.0 }, forKey: .objectIDs)
      try container.encode(objectIDswithPositions.map { $0.1 }, forKey: .positions)

    case .objectIDs(let objectsIDs):
      try container.encode(objectsIDs, forKey: .objectIDs)
    }

  }

}

public extension InsightsEvent.Resources {

  enum Error: Swift.Error {
    case decodingFailure
  }

}

extension InsightsEvent.Resources.Error: LocalizedError {

  public var errorDescription: String? {
    switch self {
    case .decodingFailure:
      return "Neither \(InsightsEvent.Resources.CodingKeys.filters.rawValue), nor \(InsightsEvent.Resources.CodingKeys.objectIDs.rawValue) key found on decoder"
    }
  }

}
