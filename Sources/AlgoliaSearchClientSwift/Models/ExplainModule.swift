//
//  ExplainModule.swift
//  
//
//  Created by Vladislav Fitc on 23/03/2020.
//

import Foundation

public enum ExplainModule: Codable {
  case matchAlternatives
  case other(String)
}

extension ExplainModule: RawRepresentable {

  public var rawValue: String {
    switch self {
    case .matchAlternatives: return "match.alternatives"
    case .other(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    case ExplainModule.matchAlternatives.rawValue: self = .matchAlternatives
    default: self = .other(rawValue)
    }
  }

}
