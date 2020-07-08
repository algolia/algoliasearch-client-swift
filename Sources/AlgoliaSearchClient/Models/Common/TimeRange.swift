//
//  TimeRange.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

public struct TimeRange {

  /// Lower bound of the time range.
  public let from: Date

  /// Upper bound of the time range
  public let until: Date

  public init(from: Date, until: Date) {
    self.from = from
    self.until = until
  }

}

extension TimeRange: Codable {

  enum CodingKeys: String, CodingKey {
    case from, until
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let fromTimestamp: TimeInterval = try container.decode(forKey: .from)
    let untilTimestamp: TimeInterval = try container.decode(forKey: .until)
    self.from = Date(timeIntervalSince1970: fromTimestamp)
    self.until = Date(timeIntervalSince1970: untilTimestamp)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(from.timeIntervalSince1970, forKey: .from)
    try container.encode(until.timeIntervalSince1970, forKey: .until)
  }

}
