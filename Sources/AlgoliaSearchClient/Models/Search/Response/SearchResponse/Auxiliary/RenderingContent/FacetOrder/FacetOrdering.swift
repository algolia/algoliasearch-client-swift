//
//  FacetOrdering.swift
//  
//
//  Created by Vladislav Fitc on 15/06/2021.
//

import Foundation

/// Facets and facets values ordering rules container
public struct FacetOrdering {

  /// The ordering of facets.
  public let facets: FacetsOrder

  /// The ordering of facet values, within an individual list.
  public let values: [Attribute: FacetValuesOrder]

  /**
   - parameters:
     - facets: The ordering of facets.
     - values: The ordering of facet values, within an individual list.
   */
  public init(facets: FacetsOrder = .init(),
              values: [Attribute: FacetValuesOrder] = [:]) {
    self.facets = facets
    self.values = values
  }

}

extension FacetOrdering: Codable {

  enum CodingKeys: String, CodingKey {
    case facets
    case values
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.facets = try container.decodeIfPresent(forKey: .facets) ?? FacetsOrder()
    let rawValues = try container.decodeIfPresent([String: FacetValuesOrder].self, forKey: .values) ?? [:]
    self.values = rawValues.mapKeys(Attribute.init)
  }

}
