//
//  MultiSearchQuery.swift
//  
//
//  Created by Vladislav Fitc on 05/11/2021.
//

import Foundation

/// Polymorphic wrapper for either and IndexedQuery or an IndexedFacetQuery to perform a multi-index search
public enum MultiSearchQuery {

  case hitsSearch(IndexedQuery)
  case facetsSearch(IndexedFacetQuery)

  /**
   - Parameter indexedQuery: The IndexedQuery to wrap
   */
  public init(_ indexedQuery: IndexedQuery) {
    self = .hitsSearch(indexedQuery)
  }

  /**
   - Parameter indexedFacetQuery: The IndexedFacetQuery to wrap
   */
  public init(_ indexedFacetQuery: IndexedFacetQuery) {
    self = .facetsSearch(indexedFacetQuery)
  }

}

extension MultiSearchQuery: Encodable {

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .facetsSearch(let facetsSearch):
      try facetsSearch.encode(to: encoder)
    case .hitsSearch(let hitsSearch):
      try hitsSearch.encode(to: encoder)
    }
  }

}
