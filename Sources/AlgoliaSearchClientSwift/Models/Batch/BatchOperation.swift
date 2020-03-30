//
//  BatchOperation.swift
//  
//
//  Created by Vladislav Fitc on 18/03/2020.
//

import Foundation

public struct BatchOperation<T: Codable>: Codable {

  public let action: Action
  public let body: T

}

extension BatchOperation: Equatable where T: Equatable {}

extension BatchOperation {
    
  static func add(_ object: T) -> BatchOperation {
    return .init(action: .addObject, body: object)
  }
    
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
