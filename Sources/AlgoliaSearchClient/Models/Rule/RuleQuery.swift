//
//  RuleQuery.swift
//  
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation

public struct RuleQuery {

  /// Full text query.
  /// - Engine default: ""
  public var query: String?

  /// When not null, restricts matches to rules with a specific Anchoring. Otherwise all Anchoring may match.
  /// - Engine default: null
  public var anchoring: Rule.Anchoring?

  /// Restricts matches to contextual rules with a specific context (exact match).
  public var context: String?

  /// Requested page.
  /// - Engine default: 0
  public var page: Int?

  /// Maximum number of hits in a page. Minimum is 1, maximum is 1000.
  /// Engine default: 20
  public var hitsPerPage: Int?

  /// When specified, restricts matches to Rule with a specific Rule.enabled.
  /// When absent (default), all Rule are retrieved, regardless of their Rule.enabled.
  /// Engine default: null
  public var isEnabled: Bool?

  public init() {}

}

extension RuleQuery: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.query = value
  }

}

extension RuleQuery: Builder {}

extension RuleQuery: Codable {

  enum CodingKeys: String, CodingKey {
    case query
    case anchoring
    case context
    case page
    case hitsPerPage
    case isEnabled = "enabled"
  }

}
