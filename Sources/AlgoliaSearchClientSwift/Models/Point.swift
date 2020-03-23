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

extension Point: RawRepresentable {
  
  public var rawValue: [Double] {
    return [latitude, longitude]
  }
  
  public init?(rawValue: [Double]) {
    guard rawValue.count > 1 else { return nil }
    self.init(latitude: rawValue[0], longitude: rawValue[1])
  }
  
}

extension Point: Codable {
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let stringValue = try container.decode(String.self)
    let rawValue = stringValue.split(separator: ",").compactMap(Double.init)
    guard rawValue.count == 2 else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Decoded string must contain two floating point values separated by comma character")
    }
    self.init(rawValue: rawValue)!
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode("\(latitude),\(longitude)")
  }
  
}
