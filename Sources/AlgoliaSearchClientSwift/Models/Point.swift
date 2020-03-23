//
//  Point.swift
//  
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation

/**
 A set of geo-coordinates [latitude] and [longitude].
 */

public struct Point: Equatable {
  
  public let latitude: Double
  public let longitude: Double
  
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
  
}

extension Point: Codable {
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode([Double].self)
    self.init(latitude: rawValue[0], longitude: rawValue[1])
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode([latitude, longitude])
  }
  
}
