//
//  BatchOperation.swift
//  
//
//  Created by Vladislav Fitc on 18/03/2020.
//

import Foundation

struct Empty: Codable {
  
  init() {}
  
  init(from decoder: Decoder) throws {
    self.init()
  }
  
  func encode(to encoder: Encoder) throws {}
  
}

protocol ObjectIDContainer {
  var objectID: ObjectID { get }
}

public struct ObjectWrapper<T: Codable>: ObjectIDContainer, Codable {
  
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
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(objectID, forKey: .objectID)
    try object.encode(to: encoder)
  }
  
  enum CodingKeys: String, CodingKey {
    case objectID
  }
  
}

public struct BatchOperation<T: Codable>: Codable {

  public let action: Action
  public let body: T

}

extension JSON {
  
  var containsObjectID: Bool {
    guard case .dictionary(let dictionary) = self else { return false }
    return dictionary.keys.contains(ObjectWrapper<Empty>.CodingKeys.objectID.rawValue)
  }
  
}

//typealias ObjectIDBatchOperation<S: Codable> = BatchOperation<ObjectWrapper<S>>

public extension BatchOperation {
    
  static func add(_ object: T) -> BatchOperation {
    return .init(action: .addObject, body: object)
  }
  
}


extension BatchOperation {
    
  static func update<T: Codable>(objectID: ObjectID, _ object: T) -> BatchOperation<ObjectWrapper<T>> {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: .updateObject, body: objectWrapper)
  }
  
  static func partialUpdate<T: Codable>(objectID: ObjectID, _ object: T, createIfNotExists: Bool) -> BatchOperation<ObjectWrapper<T>> {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate, body: objectWrapper)
  }
  
  static func partialUpdate(objectID: ObjectID, partialUpdate: PartialUpdate, createIfNotExists: Bool) -> BatchOperation<ObjectWrapper<PartialUpdate>> {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: partialUpdate)
    return .init(action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate, body: objectWrapper)
  }

  
  static func delete(objectID: ObjectID) -> BatchOperation<ObjectWrapper<Empty>> {
    return .init(action: .deleteObject, body: ObjectWrapper(objectID: objectID))
  }
  
}



public extension BatchOperation {

  enum Action: String, Codable {
    case addObject
    case updateObject
    case partialUpdateObject
    case partialUpdateObjectNoCreate
    case deleteObject
  }

}
