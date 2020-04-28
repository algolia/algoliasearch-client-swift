//
//  DecompoundedAttributes.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

/**
 Specify on which attributes in your index Algolia should apply word-splitting (“decompounding”).
 A compound word refers to a word that is formed by combining smaller words without spacing.
 They are called noun phrases, or nominal groups, and they are particularly present in German.
 An example is Baumhaus, which is a contraction of Baum and Haus.
 The goal of decompounding, regarding the previous example, is to index both Baum and Haus separately,
 instead of as a single word.
*/

public struct DecompoundedAttributes: Equatable {

  private let storage: [Language: [Attribute]]

  init(storage: [Language: [Attribute]]) {
    self.storage = storage
  }

  public func attributes(for language: AllowedLanguage) -> [Attribute]? {
    return storage[language.language]
  }

}

extension DecompoundedAttributes: ExpressibleByDictionaryLiteral {

  public init(dictionaryLiteral elements: (AllowedLanguage, [Attribute])...) {
    var storage: [Language: [Attribute]] = [:]
    for (language, attributes) in elements {
      storage[language.language] = attributes
    }
    self.init(storage: storage)
  }

}

extension DecompoundedAttributes {

  public enum AllowedLanguage {

    case german
    case finnish
    case dutch

    var language: Language {
      switch self {
      case .german: return .german
      case .finnish: return .finnish
      case .dutch: return .dutch
      }
    }

  }

}

extension DecompoundedAttributes: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawStorage = try container.decode([String: [String]].self)
    var storage: [Language: [Attribute]] = [:]
    for (rawLanguage, rawAttributes) in rawStorage {
      let language = Language(rawValue: rawLanguage)
      let attributes = rawAttributes.map(Attribute.init)
      storage[language] = attributes
    }
    self.init(storage: storage)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    var rawStorage: [String: [String]] = [:]
    for (language, attributes) in storage {
      rawStorage[language.rawValue] = attributes.map(\.rawValue)
    }
    try container.encode(rawStorage)
  }

}
