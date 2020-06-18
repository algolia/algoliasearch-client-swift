//
//  Rule+AutomaticFacetFilters.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

extension Rule {

  public struct AutomaticFacetFilters: Codable {

    /// Attribute to filter on. This must match Pattern.Facet.attribute.
    public let attribute: Attribute

    /// Score for the filter. Typically used for optional or disjunctive filters.
    public let score: Int?

    /**
    Whether the filter is disjunctive (true) or conjunctive (false).
     
    If the filter applies multiple times, e.g.
    because the query string contains multiple values of the same facet, the multiple occurrences are combined
    with an AND operator by default (conjunctive mode). If the filter is specified as disjunctive,
    however, multiple occurrences are combined with an OR operator instead.
    */
    public let isDisjunctive: Bool?

    public init(attribute: Attribute, score: Int? = nil, isDisjunctive: Bool? = nil) {
      self.attribute = attribute
      self.score = score
      self.isDisjunctive = isDisjunctive
    }

  }

}

extension Rule.AutomaticFacetFilters {

  enum CodingKeys: String, CodingKey {
    case attribute = "facet"
    case score
    case isDisjunctive = "disjunctive"
  }

}
