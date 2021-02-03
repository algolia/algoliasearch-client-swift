//
//  CompoundsDictionary.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct CompoundsDictionary: CustomDictionary {

  public static var name: DictionaryName = .compounds

}

public extension CompoundsDictionary {

  struct Entry: DictionaryEntry, Codable, Equatable {

    public let objectID: ObjectID
    public let language: Language

    /// When decomposition is empty: adds word as a compound atom.
    /// For example, atom “kino” decomposes the query “kopfkino” into “kopf” and “kino”.
    /// When decomposition isn’t empty: creates a decomposition exception.
    /// For example, when decomposition is set to ["hund", "hutte"], exception “hundehutte” decomposes the word into “hund” and “hutte”, discarding the linking morpheme “e”.
    public let word: String

    /// When empty, the key word is considered as a compound atom.
    /// Otherwise, it is the decomposition of word.
    public let decomposition: [String]

    public init(objectID: ObjectID, language: Language, word: String, decomposition: [String]) {
      self.objectID = objectID
      self.language = language
      self.word = word
      self.decomposition = decomposition
    }

  }

}
