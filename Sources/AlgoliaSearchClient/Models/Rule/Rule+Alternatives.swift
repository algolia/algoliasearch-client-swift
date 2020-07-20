//
//  Rule+Alternatives.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

extension Rule {

  public enum Alternatives: RawRepresentable, Encodable {

    case `true`
    case `false`

    public var rawValue: Bool {
      switch self {
      case .true:
        return true
      case .false:
        return false
      }
    }

    public init(rawValue: Bool) {
      self = rawValue ? .true : .false
    }

  }

}

extension Rule.Alternatives: ExpressibleByBooleanLiteral {

  public init(booleanLiteral value: Bool) {
    self = value ? .true : .false
  }

}

extension Rule.Alternatives: Decodable {
  
  public init(from decoder: Decoder) throws {
    let boolContainer = try BoolContainer(from: decoder)
    self = boolContainer.rawValue ? .true : .false
  }
  
}
