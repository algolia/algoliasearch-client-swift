//
//  FacetValuesOrder.swift
//  
//
//  Created by Vladislav Fitc on 15/06/2021.
//

import Foundation

/// Facet values ordering rule container
public struct FacetValuesOrder {

  /// Pinned order of facet values.
  public let order: [String]

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

extension FacetValuesOrder: Codable {

  enum CodingKeys: String, CodingKey {
    case order
    case sortRemainingBy
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.order = try container.decodeIfPresent(forKey: .order) ?? []
    self.sortRemainingBy = try container.decodeIfPresent(forKey: .sortRemainingBy)
  }

}
