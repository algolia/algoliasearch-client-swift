//
//  RankingCriterion.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//
// swiftlint:disable cyclomatic_complexity

import Foundation

public enum RankingCriterion: Codable, Equatable {

  case asc(Attribute)
  case desc(Attribute)
  case typo
  case geo
  case words
  case filters
  case proximity
  case attribute
  case exact
  case custom

}

extension RankingCriterion: RawRepresentable {

  private enum Prefix: String {
    case asc
    case desc
    case typo
    case geo
    case words
    case filters
    case proximity
    case attribute
    case exact
    case custom
  }

  public var rawValue: String {
    switch self {
    case .asc(let attribute):
      return PrefixedString(prefix: Prefix.asc.rawValue, value: attribute.rawValue).description
    case .desc(let attribute):
      return PrefixedString(prefix: Prefix.desc.rawValue, value: attribute.rawValue).description
    case .attribute:
      return Prefix.attribute.rawValue
    case .custom:
      return Prefix.custom.rawValue
    case .exact:
      return Prefix.exact.rawValue
    case .filters:
      return Prefix.filters.rawValue
    case .geo:
      return Prefix.geo.rawValue
    case .proximity:
      return Prefix.proximity.rawValue
    case .typo:
      return Prefix.typo.rawValue
    case .words:
      return Prefix.words.rawValue
    }
  }

  public init?(rawValue: String) {
    if let ascValue = PrefixedString.matching(rawValue, prefix: Prefix.asc.rawValue) {
      self = .asc(.init(rawValue: ascValue))
    } else if let descValue = PrefixedString.matching(rawValue, prefix: Prefix.desc.rawValue) {
      self = .desc(.init(rawValue: descValue))
    } else if let prefix = Prefix(rawValue: rawValue) {
      switch prefix {
      case .attribute:
        self = .attribute
      case .custom:
        self = .custom
      case .exact:
        self = .exact
      case .filters:
        self = .filters
      case .geo:
        self = .geo
      case .proximity:
        self = .proximity
      case .typo:
        self = .typo
      case .words:
        self = .words
      default:
        return nil
      }
    } else {
      return nil
    }
  }

}
