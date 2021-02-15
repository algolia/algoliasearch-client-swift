//
//  StopwordsDictionary.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct StopwordsDictionary: CustomDictionary {

  public static var name: DictionaryName = .stopwords

}

extension StopwordsDictionary {

  public struct Entry: DictionaryEntry, Codable, Equatable {

    public enum State: String, Codable {
      case enabled
      case disabled
    }

    public let objectID: ObjectID
    public let language: Language

    /// The stop word being added or modified. When `word` already exists in the standard dictionary provided by Algolia, the entry can be overridden by the one provided by the user.
    public let word: String

    /// The state of the entry
    public let state: State?

    public init(objectID: ObjectID, language: Language, word: String, state: State) {
      self.objectID = objectID
      self.language = language
      self.word = word
      self.state = state
    }

  }

}
