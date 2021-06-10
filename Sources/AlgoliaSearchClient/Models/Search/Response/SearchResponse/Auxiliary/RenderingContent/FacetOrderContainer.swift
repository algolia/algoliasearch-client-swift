//
//  FacetOrderContainer.swift
//  
//
//  Created by Vladislav Fitc on 17/03/2021.
//

import Foundation

public struct FacetOrderContainer: Codable {

  public let facetOrdering: FacetOrdering

  public init(facetOrdering: FacetOrdering = .init()) {
    self.facetOrdering = facetOrdering
  }

}

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
    self.facets = try container.decode(forKey: .facets)
    let rawValues = try container.decode([String: FacetValuesOrder].self, forKey: .values)
    self.values = rawValues.mapKeys(Attribute.init)
  }

}

public struct FacetsOrder: Codable {

  /// Pinned order of facet lists.
  public let order: [Attribute]

  /// - parameter order: pinned order of facet lists.
  public init(order: [Attribute] = []) {
    self.order = order
  }

}

public struct FacetValuesOrder: Codable {

  /// Pinned order of facet values.
  public let order: [String]?

  /// How to display the remaining items.
  public let sortRemainingBy: SortRule?

  /// Rule defining the sort order of facet values.
  public enum SortRule: String, Codable {
    /// alphabetical (ascending)
    case alpha

    /// facet count (descending)
    case count

    /// hidden (show only pinned values)
    case hidden
  }

  /**
   - parameters:
     - order: Pinned order of facet values.
     - sortRemainingBy: How to display the remaining items.
   */
  public init(order: [String] = [],
              sortRemainingBy: SortRule? = nil) {
    self.order = order
    self.sortRemainingBy = sortRemainingBy
  }

}
