//
//  DictionaryEntry.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public protocol DictionaryEntry {

  /// Unique identifier of the entry to add or override.
  var objectID: ObjectID { get }

  /// Language supported by the dictionary.
  var language: Language { get }

}
