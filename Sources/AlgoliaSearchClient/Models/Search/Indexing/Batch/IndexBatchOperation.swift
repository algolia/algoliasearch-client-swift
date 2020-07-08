//
//  IndexBatchOperation.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation

struct IndexBatchOperation: Codable {

  /// IndexName targeted by this operation
  let indexName: IndexName

  /// Type of BatchOperation to execute.
  let operation: BatchOperation

}

extension IndexBatchOperation {

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    indexName = try container.decode(forKey: .indexName)
    operation = try .init(from: decoder)
  }

  func encode(to encoder: Encoder) throws {
    try operation.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(indexName, forKey: .indexName)
  }

  enum CodingKeys: String, CodingKey {
    case indexName
  }

}
