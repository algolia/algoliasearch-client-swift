//
//  IndexOperation.swift
//  
//
//  Created by Vladislav Fitc on 01/04/2020.
//

import Foundation

struct IndexOperation {

  let action: Action
  let destination: IndexName
  let scopes: [ScopeComponent]?

}

extension IndexOperation {

  enum Action: String, Codable {
    case copy, move
  }

}

extension IndexOperation: Codable {

  enum CodingKeys: String, CodingKey {
    case action = "operation"
    case destination
    case scopes = "scope"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.action = try container.decode(forKey: .action)
    self.destination = try container.decode(forKey: .destination)
    self.scopes = try container.decodeIfPresent(forKey: .scopes)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(action, forKey: .action)
    try container.encode(destination, forKey: .destination)
    try container.encodeIfPresent(scopes, forKey: .scopes)
  }

}
