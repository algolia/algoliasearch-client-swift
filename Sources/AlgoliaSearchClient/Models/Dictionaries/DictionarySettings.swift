//
//  DictionarySettings.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct DictionarySettings: Codable, Equatable {

  public let disableStandardEntries: DisableStandardEntries?

  public init(disableStandardEntries: DisableStandardEntries?) {
    self.disableStandardEntries = disableStandardEntries
  }

}

extension DictionarySettings {

  /// Map of language supported by the dictionary to a boolean value.
  /// When set to true, the standard entries for the language are disabled.
  /// Changes are set for the given languages only. To re-enable standard entries, set the language to false.
  public struct DisableStandardEntries: Codable, Equatable {

    public let stopwords: [Language: Bool]

    public init(stopwords: [Language: Bool]) {
      self.stopwords = stopwords
    }

    enum CodingKeys: String, CodingKey {
      case stopwords
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(stopwords.mapKeys(\.rawValue), forKey: .stopwords)
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      stopwords = try container.decode([String: Bool].self, forKey: .stopwords).mapKeys(Language.init(rawValue:))
    }

  }

}
