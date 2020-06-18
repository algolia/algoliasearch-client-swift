//
//  CustomRankingCriterion.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation

public enum CustomRankingCriterion: Codable, Equatable {
  case asc(Attribute)
  case desc(Attribute)
}

extension CustomRankingCriterion: RawRepresentable {

  private enum Prefix: String {
    case asc
    case desc
  }

  public var rawValue: String {
     switch self {
     case .asc(let attribute):
       return PrefixedString(prefix: Prefix.asc.rawValue, value: attribute.rawValue).description
     case .desc(let attribute):
       return PrefixedString(prefix: Prefix.desc.rawValue, value: attribute.rawValue).description
    }
  }

  public init?(rawValue: String) {
    guard
      let prefixedString = PrefixedString(rawValue: rawValue),
      let prefix = Prefix(rawValue: prefixedString.prefix) else {
        return nil
    }
    switch prefix {
    case .asc:
      self = .asc(.init(rawValue: prefixedString.value))
    case .desc:
      self = .desc(.init(rawValue: prefixedString.value))
    }
  }

}
