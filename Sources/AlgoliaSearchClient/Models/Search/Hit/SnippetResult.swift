//
//  SnippetResult.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

/// Snippet result for an attribute of a hit.
public struct SnippetResult: Codable, Hashable {

  /// Value of this snippet.
  public let value: String

  /// Match level.
  public let matchLevel: MatchLevel

}
