//
//  IndexQuery.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

struct IndexQuery {
  let indexName: IndexName
  let query: Query
}

extension IndexQuery: Codable {

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
