//
//  Synonym.swift
//  
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation

public enum Synonym {

  case oneWay(objectID: ObjectID, input: String, synonyms: [String])
  case multiWay(objectID: ObjectID, synonyms: [String])
  case alternativeCorrection(objectID: ObjectID, word: String, corrections: [String], typo: Typo)
  case placeholder(objectID: ObjectID, placeholder: String, replacements: [String])

  /// Unique identifier for the synonym.
  public var objectID: ObjectID {
    switch self {
    case .oneWay(objectID: let objectID, _, _):
      return objectID
    case .multiWay(objectID: let objectID, _):
      return objectID
    case .alternativeCorrection(objectID: let objectID, word: _, corrections: _, typo: _):
      return objectID
    case .placeholder(objectID: let objectID, placeholder: _, replacements: _):
      return objectID
    }
  }

  var type: SynonymType {
    switch self {
    case .oneWay:
      return .oneWay
    case .multiWay:
      return .multiWay
    case .alternativeCorrection(objectID: _, word: _, corrections: _, typo: .one):
      return .altCorrection1
    case .alternativeCorrection(objectID: _, word: _, corrections: _, typo: .two):
      return .altCorrection2
    case .placeholder:
      return .placeholder
    }
  }

  public enum Typo {
    case one, two
  }

}

extension Synonym: Codable {

  enum CodingKeys: String, CodingKey {
    case objectID
    case type
    case synonyms
    case input
    case word
    case corrections
    case placeholder
    case replacements
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let objectID: ObjectID = try container.decode(forKey: .objectID)
    let type: SynonymType = try container.decode(forKey: .type)
    switch type {
    case .oneWay:
      let input: String = try container.decode(forKey: .input)
      let synonyms: [String] = try container.decode(forKey: .synonyms)
      self = .oneWay(objectID: objectID, input: input, synonyms: synonyms)
    case .multiWay:
      let synonyms: [String] = try container.decode(forKey: .synonyms)
      self = .multiWay(objectID: objectID, synonyms: synonyms)
    case .altCorrection1, .altCorrection2:
      let typo: Typo = type == .altCorrection1 ? .one : .two
      let word: String = try container.decode(forKey: .word)
      let corrections: [String] = try container.decode(forKey: .corrections)
      self = .alternativeCorrection(objectID: objectID, word: word, corrections: corrections, typo: typo)
    case .placeholder:
      let placeholder: String = try container.decode(forKey: .placeholder)
      let replacements: [String] = try container.decode(forKey: .replacements)
      self = .placeholder(objectID: objectID, placeholder: placeholder, replacements: replacements)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
    try container.encode(objectID, forKey: .objectID)
    switch self {
    case .oneWay(_, let input, let synonyms):
      try container.encode(input, forKey: .input)
      try container.encode(synonyms, forKey: .synonyms)
    case .multiWay(_, let synonyms):
      try container.encode(synonyms, forKey: .synonyms)
    case .alternativeCorrection(_, let word, let corrections, _):
      try container.encode(word, forKey: .word)
      try container.encode(corrections, forKey: .corrections)
    case .placeholder(_, let placeholder, let replacements):
      try container.encode(placeholder, forKey: .placeholder)
      try container.encode(replacements, forKey: .replacements)
    }
  }

}
