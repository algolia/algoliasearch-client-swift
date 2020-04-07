//
//  IndexWrapper.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation

public struct IndexWrapper<T: Codable>: Codable {
  
  public let indexName: IndexName
  public let object: T
  
  public init(indexName: IndexName, object: T) {
    self.indexName = indexName
    self.object = object
  }
  
}

extension IndexWrapper where T == Empty {
  
  init(indexName: IndexName) {
    self.indexName = indexName
    self.object = .init()
  }
  
}

extension IndexWrapper {
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    indexName = try container.decode(forKey: .indexName)
    object = try .init(from: decoder)
  }
  
  public func encode(to encoder: Encoder) throws {
    try object.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(indexName, forKey: .indexName)
  }
  
  enum CodingKeys: String, CodingKey {
    case indexName
  }
  
}
