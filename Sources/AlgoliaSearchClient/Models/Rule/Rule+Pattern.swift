//
//  Rule+Pattern.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

extension Rule {

  /**
  An empty Pattern is only allowed when the Anchoring is set to Anchoring.is.
  Special characters ({, }, : and \) must be escaped by preceding them with a backslash (\) if they are to be treated as literals.
  */
  public enum Pattern {
    case facet(Attribute)
    case literal(String)
  }

}

extension Rule.Pattern: Codable {

  static let facetPrefix = "{facet:"

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    if rawValue.range(of: Self.facetPrefix) != nil, rawValue.hasSuffix("}") {
      let facetAttribute = String(rawValue.dropFirst(Self.facetPrefix.count).dropLast())
      self = .facet(Attribute(rawValue: facetAttribute))
    } else {
      self = .literal(rawValue)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    let rawValue: String
    switch self {
    case .facet(let attribute):
      rawValue = Rule.Pattern.facetPrefix + attribute.rawValue + "}"
    case .literal(let literal):
      rawValue = literal
    }
    try container.encode(rawValue)
  }

}
