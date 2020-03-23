//
//  AroundPrecision.swift
//  
//
//  Created by Vladislav Fitc on 23/03/2020.
//

import Foundation

public struct AroundPrecision: Codable {
  
  public let from: Double
  public let value: Double
  
  public init(from: Double, value: Double) {
    self.from = from
    self.value = value
  }
  
}
