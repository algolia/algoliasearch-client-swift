//
//  AdvancedSyntaxFeatures.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

enum AdvancedSyntaxFeatures: Equatable {
  case exactPhrase
  case excludeWords
  case other(String)
}

extension AdvancedSyntaxFeatures: RawRepresentable {
  
  var rawValue: String {
    switch self {
    case .exactPhrase:
      return "exactPhrase"
    case .excludeWords:
      return "excludeWords"
    case .other(let value):
      return value
    }
  }
  
  init(rawValue: String) {
    switch rawValue {
    case "exactPhrase":
      self = .exactPhrase
    case "excludeWords":
      self = .excludeWords
    default:
      self = .other(rawValue)
    }
  }
  
}
