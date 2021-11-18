//
//  IndexedQuery.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

/// The composition of search parameters with an associated index name
public struct IndexedQuery {

  /// The name of the index to search in.
  public let indexName: IndexName

  /// The Query to filter results.
  public let query: Query

  /// - parameter indexName: The name of the index to search in.
  /// - parameter query: The Query to filter results.
  public init(indexName: IndexName, query: Query) {
    self.indexName = indexName
    self.query = query
  }

}

extension IndexedQuery: Codable {

  enum CodingKeys: String, CodingKey {
    case indexName
    case query = "params"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    indexName = try container.decode(forKey: .indexName)
    query = .empty
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(indexName, forKey: .indexName)
    try container.encode(query.urlEncodedString, forKey: .query)
  }

}
