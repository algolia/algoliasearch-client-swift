//
//  Plural.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct Plural: DictionaryEntry, Codable {
    
  public let objectID: ObjectID
  public let language: Language
  
  /// List of word declensions. The entry overrides existing entries when any of these words are defined in the standard dictionary provided by Algolia.
  public let words: [String]
  
  public init(objectID: ObjectID, language: Language, words: [String]) {
    self.objectID = objectID
    self.language = language
    self.words = words
  }

}
