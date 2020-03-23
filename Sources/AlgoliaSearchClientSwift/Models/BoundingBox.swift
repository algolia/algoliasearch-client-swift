//
//  BoundingBox.swift
//  
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation

/**
 Search inside a rectangular area (in geo coordinates).
 The rectangle is defined by two diagonally opposite points (hereafter [point1] and [point2]).
*/

public struct BoundingBox: Equatable {
  
  public let point1: Point
  public let point2: Point
  
  public init(point1: Point, point2: Point) {
    self.point1 = point1
    self.point2 = point2
  }
  
}

extension BoundingBox: Codable {
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode([Double].self)
    self.init(point1: .init(latitude: rawValue[0], longitude: rawValue[1]), point2: .init(latitude: rawValue[2], longitude: rawValue[3]))
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode([point1.latitude, point1.longitude, point2.latitude, point2.longitude])
  }
  
}
