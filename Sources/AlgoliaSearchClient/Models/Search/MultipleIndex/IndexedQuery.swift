//
//  IndexedQuery.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

public struct IndexedQuery {

  public enum QueryType {
    case `default`
    case facet(Attribute)

    var rawValue: String {
      switch self {
      case .default:
        return "default"
      case .facet:
        return "facet"
      }
    }
  }

  public let indexName: IndexName
  public let query: Query
  public let type: QueryType

  public init(indexName: IndexName, query: Query) {
    self.indexName = indexName
    self.query = query
    self.type = .default
  }

  public init(indexName: IndexName, query: Query, attribute: Attribute, facetQuery: String) {
    self.indexName = indexName
    var parameters = query.customParameters ?? [:]
    parameters["facetQuery"] = .init(facetQuery)
    self.query = query
      .set(\.customParameters, to: parameters)
    self.type = .facet(attribute)
  }

}

extension IndexedQuery: Codable {

  enum CodingKeys: String, CodingKey {
    case indexName
    case query = "params"
    case type
    case facet
    case facetQuery
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    indexName = try container.decode(forKey: .indexName)
    query = .empty
    type = .default
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(indexName, forKey: .indexName)
    try container.encode(query.urlEncodedString, forKey: .query)
    try container.encode(type.rawValue, forKey: .type)
    if case .facet(let facet) = type {
      try container.encode(facet.rawValue, forKey: .facet)
    }
  }

}
