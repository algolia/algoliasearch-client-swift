//
//  AroundPrecision.swift
//  
//
//  Created by Vladislav Fitc on 23/03/2020.
//

import Foundation

public struct AroundPrecision: Codable, Equatable {

  public let from: Double
  public let value: Double

  public init(from: Double, value: Double) {
    self.from = from
    self.value = value
  }

}

extension AroundPrecision: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: UInt) {
    self.from = 0
    self.value = Double(value)
  }

}

extension AroundPrecision: ExpressibleByFloatLiteral {

  public init(floatLiteral value: Double) {
    self.from = 0
    self.value = value
  }

}

extension AroundPrecision: URLEncodable {

  public var urlEncodedString: String {
    return "{\"from\":\(from),\"value\":\(value)}"
  }

}
