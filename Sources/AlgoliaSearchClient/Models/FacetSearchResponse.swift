//
//  FacetSearchResponse.swift
//
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct FacetSearchResponse: Codable {

  /// The list of Facet.
  public let facetHits: [Facet]

  /// Whether the count returned for each facets is exhaustive.
  public let exhaustiveFacetsCount: Bool

  /// Processing time.
  public let processingTimeMS: TimeInterval

}
