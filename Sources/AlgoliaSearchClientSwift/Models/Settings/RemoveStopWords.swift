//
//  RemoveStopWords.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

public enum RemoveStopWords {

  /**
    Enables the stop word functionality, ensuring that stop words are removed from consideration in a search.
    The languages supported here are either every language (this is the default, see list of [Language]),
    or those set by queryLanguages. See queryLanguages example below.
  */
  case `true`

  /**
   Disables stop word functionality, allowing stop words to be taken into account in a search.
   */
  case `false`

  /**
   A list of Language for which ignoring plurals should be enabled.
   This list of queryLanguages will override any values that you may have set in Settings.queryLanguages.
  */
  case queryLanguages([Language])

}

extension RemoveStopWords: Codable {

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

extension RemoveStopWords: Equatable {}
