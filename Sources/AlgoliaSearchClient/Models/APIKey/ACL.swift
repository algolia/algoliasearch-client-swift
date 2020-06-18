//
//  ACL.swift
//  
//
//  Created by Vladislav Fitc on 08/04/2020.
//

import Foundation

public enum ACL: String, Codable {

  /// Allows search.
  case search

  /// Allows retrieval of all index contents via the browse API.
  case browse

  /// Allows adding/updating an object in the index. (Copying/moving indices are also allowed with this permission.)
  case addObject

  /// Allows deleting an existing object.
  case deleteObject

  /// Allows listing all accessible indices.
  case listIndices = "listIndexes"

  /// Allows deleting index content.
  case deleteIndex

  /// Allows getting index settings.
  case settings

  /// Allows changing index settings.
  case editSettings

  /// Allows retrieval of analytics through the analytics API.
  case analytics

  /// Allows the interaction with the Recommendation API.
  case recommendation

  /// Allows retrieving data through the Usage API.
  case usage

  /// Allows getting the logs.
  case logs

  /// Disables the Settings.unretrievableAttributes feature for all operations returning records.
  case seeUnretrievableAttributes

}
