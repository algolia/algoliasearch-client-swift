//
//  SynonymQuery.swift
//  
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation

public struct SynonymQuery {
  
  /// Full text query.
  /// - Engine default: ""
  public var query: String?
  
  public init() {}

}

extension SynonymQuery: ExpressibleByStringLiteral {
  
  public init(stringLiteral value: String) {
    self.query = value
  }
  
}

extension SynonymQuery: Builder {}

extension SynonymQuery: Codable {
  
}
