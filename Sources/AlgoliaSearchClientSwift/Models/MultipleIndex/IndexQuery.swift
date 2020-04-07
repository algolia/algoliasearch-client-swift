//
//  IndexQuery.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

struct IndexQuery  {
  let indexName: IndexName
  let query: Query
}

extension IndexQuery: Codable {
  
  enum CodingKeys: String, CodingKey {
    case indexName
    case query = "params"
  }
  
}
