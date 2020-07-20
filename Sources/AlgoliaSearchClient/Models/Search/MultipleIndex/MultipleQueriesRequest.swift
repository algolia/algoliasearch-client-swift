//
//  MultipleQueriesRequest.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation

struct MultipleQueriesRequest {

  let requests: [IndexedQuery]
  let strategy: MultipleQueriesStrategy

}

extension MultipleQueriesRequest: Codable {

  enum CodingKeys: String, CodingKey {
    case requests
    case strategy
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.requests = try container.decode(forKey: .requests)
    self.strategy = try container.decodeIfPresent(forKey: .strategy) ?? .none
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(requests, forKey: .requests)
    try container.encodeIfPresent(strategy, forKey: .strategy)
  }

}
