//
//  MultipleQueriesRequest.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation

struct MultipleQueriesRequest {

  let requests: [MultiSearchQuery]
  let strategy: MultipleQueriesStrategy

}

extension MultipleQueriesRequest: Encodable {

  enum CodingKeys: String, CodingKey {
    case requests
    case strategy
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(requests, forKey: .requests)
    try container.encodeIfPresent(strategy, forKey: .strategy)
  }

}
