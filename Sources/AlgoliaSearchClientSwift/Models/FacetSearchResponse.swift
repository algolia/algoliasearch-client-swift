//
//  FacetSearchResponse.swift
//
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct FacetSearchResponse: Codable {
  
  /**
   The list of Facet.
   */
  let facets: [Facet]
  
  /**
   Whether the count returned for each facets is exhaustive.
   */
  let exhaustiveFacetsCount: Bool
  
  /**
   Processing time.
   */
  let processingTimeMS: TimeInterval
  
}
