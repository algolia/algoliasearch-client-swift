//
//  DictionarySettings.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct DictionarySettings: Codable {
  
  struct StopWords: Codable {
    
    /// Map of language supported by the dictionary to a boolean value.
    /// When set to true, the standard entries for the language are disabled.
    /// Changes are set for the given languages only. To re-enable standard entries, set the language to false.
    let disableStandardEntries: [Language: Bool]
    
    func encode(to encoder: Encoder) throws {
      try disableStandardEntries.mapKeys(\.rawValue).encode(to: encoder)
    }
    
    init(from decoder: Decoder) throws {
      disableStandardEntries = try [String: Bool](from: decoder).mapKeys(Language.init(rawValue:))
    }
    
  }
  
  let stopwords: StopWords?
  
}
