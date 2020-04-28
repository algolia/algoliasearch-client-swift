//
//  ObjectWrapper.swift
//  
//
//  Created by Vladislav Fitc on 30/03/2020.
//

import Foundation

public struct ObjectWrapper<T: Codable>: Codable {

  public let objectID: ObjectID
  public let object: T

  public init(objectID: ObjectID, object: T) {
    self.objectID = objectID
    self.object = object
  }

}

extension ObjectWrapper where T == Empty {

  init(objectID: ObjectID) {
    self.objectID = objectID
    self.object = .init()
  }

}

extension ObjectWrapper {

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    objectID = try container.decode(forKey: .objectID)
    object = try .init(from: decoder)
  }

  public func encode(to encoder: Encoder) throws {
    try object.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(objectID, forKey: .objectID)
  }

  enum CodingKeys: String, CodingKey {
    case objectID
  }

}
