//
//  IgnorePlurals.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

public enum IgnorePlurals {
  
  /**
   Enables the ignore plurals functionality, where singulars and plurals are considered equivalent (foot = feet).
   The languages supported here are either every language or those set by [Settings.queryLanguages]
   */
  case `true`
  
  /**
   Which disables ignore plurals, where singulars and plurals are not considered the same for matching purposes
   (foot will not find feet).
  */
  case `false`
  
  /**
   A list of Language for which ignoring plurals should be enabled.
   This list of queryLanguages will override any values that you may have set in Settings.queryLanguages.
  */
  case queryLanguages([Language])
  
}

extension IgnorePlurals: Codable {
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let isTrue = try? container.decode(Bool.self) {
      self = isTrue ? .true : .false
    } else {
      let languages = try container.decode([Language].self)
      self = .queryLanguages(languages)
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var singleValueContainer = encoder.singleValueContainer()
    switch self {
    case .true:
      try singleValueContainer.encode(true)
    case .false:
      try singleValueContainer.encode(false)
    case .queryLanguages(let languages):
      try singleValueContainer.encode(languages)
    }
  }
  
}

extension IgnorePlurals: Equatable {}
