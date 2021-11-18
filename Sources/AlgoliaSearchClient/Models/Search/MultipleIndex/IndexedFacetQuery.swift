//
//  IndexedFacetQuery.swift
//  
//
//  Created by Vladislav Fitc on 05/11/2021.
//

import Foundation

/// The composition of search for facet values parameters with an associated index name
public struct IndexedFacetQuery {

  /// The name of the index to search in.
  public let indexName: IndexName

  /// The attribute to facet on.
  public let attribute: Attribute

  /// The query to filter results.
  public let query: Query

  /// The textual query used to search for facets.
  public let facetQuery: String

  /**
   - Parameter indexName: The name of the index to search in
   - Parameter attribute: The Attribute to facet on.
   - Parameter query: The Query to filter results.
   - Parameter facetQuery: The textual query used to search for facets.
   */
  public init(indexName: IndexName,
              attribute: Attribute,
              facetQuery: String,
              query: Query) {
    self.indexName = indexName
    self.attribute = attribute
    self.facetQuery = facetQuery
    var parameters = query.customParameters ?? [:]
    parameters["facetQuery"] = .init(facetQuery)
    self.query = query.set(\.customParameters, to: parameters)
  }

}

extension IndexedFacetQuery: Encodable {

  enum CodingKeys: String, CodingKey {
    case indexName
    case query = "params"
    case type
    case facet
    case facetQuery
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(indexName, forKey: .indexName)
    try container.encode(query.urlEncodedString, forKey: .query)
    try container.encode(attribute, forKey: .facet)
    try container.encode("facet", forKey: .type)
  }

}
