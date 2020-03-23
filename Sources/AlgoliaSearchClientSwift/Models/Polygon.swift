//
//  Polygon.swift
//  
//
//  Created by Vladislav Fitc on 21/03/2020.
//

import Foundation

public struct Polygon: Equatable {
  
  public let points: [Point]
  
  public init(_ point1: Point, _ point2: Point, _ point3: Point, _ points: Point...) {
    self.init(point1, point2, point3, points)
  }
  
  init(_ point1: Point, _ point2: Point, _ point3: Point, _ points: [Point]) {
    self.points = [point1, point2, point3] + points
  }
  
}

extension Polygon: Codable {
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode([Double].self)
    let tailPoints: [Point]
    if rawValue.count == 6 {
      tailPoints = []
    } else {
      tailPoints = stride(from: rawValue.startIndex.advanced(by: 6), to: rawValue.endIndex, by: 2).map { Point(latitude: rawValue[$0], longitude: rawValue[$0+1]) }
    }
    self.init(.init(latitude: rawValue[0], longitude: rawValue[1]),
              .init(latitude: rawValue[2], longitude: rawValue[3]),
              .init(latitude: rawValue[4], longitude: rawValue[5]),
              tailPoints)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    let rawValue = points.map { [$0.latitude, $0.longitude] }.reduce([], +)
    try container.encode(rawValue)
  }
  
}
