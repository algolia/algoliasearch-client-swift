//
//  DictionarySettings.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct DictionarySettings: Codable {
  
  public let stopwords: StopWords?
  
  public init(stopwords: DictionarySettings.StopWords?) {
    self.stopwords = stopwords
  }

}

extension DictionarySettings {
  
  public struct StopWords: Codable {
    
    /// Map of language supported by the dictionary to a boolean value.
    /// When set to true, the standard entries for the language are disabled.
    /// Changes are set for the given languages only. To re-enable standard entries, set the language to false.
    public let disableStandardEntries: [Language: Bool]
    
    public init(disableStandardEntries: [Language : Bool]) {
      self.disableStandardEntries = disableStandardEntries
    }
    
    public func encode(to encoder: Encoder) throws {
      try disableStandardEntries.mapKeys(\.rawValue).encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
      disableStandardEntries = try [String: Bool](from: decoder).mapKeys(Language.init(rawValue:))
    }
    
  }
  
}

