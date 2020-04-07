//
//  BatchOperation.swift
//  
//
//  Created by Vladislav Fitc on 18/03/2020.
//

import Foundation

public struct BatchOperation: Codable, Equatable {

  public let action: Action
  public let body: JSON?
  
  init(action: Action, body: JSON? = nil) {
    self.action = action
    self.body = body
  }
  
}

extension BatchOperation {
  
  init<T: Encodable>(action: Action, bodyObject: T) {
    let body = try! JSON(bodyObject)
    self.init(action: action, body: body)
  }
  
}

extension BatchOperation {
    
  static func add<T: Encodable>(_ object: T) -> BatchOperation {
    return .init(action: .addObject, bodyObject: object)
  }
    
  static func update<T: Codable>(objectID: ObjectID, _ object: T) -> BatchOperation {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: .updateObject, bodyObject: objectWrapper)
  }
  
  static func partialUpdate<T: Codable>(objectID: ObjectID, _ object: T, createIfNotExists: Bool) -> BatchOperation {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate, bodyObject: objectWrapper)
  }
  
  static func partialUpdate(objectID: ObjectID, partialUpdate: PartialUpdate, createIfNotExists: Bool) -> BatchOperation {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: partialUpdate)
    return .init(action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate, bodyObject: objectWrapper)
  }

  static func delete(objectID: ObjectID) -> BatchOperation {
    return .init(action: .deleteObject, bodyObject: ObjectWrapper(objectID: objectID))
  }
  
  static var delete: BatchOperation {
    return .init(action: .delete)
  }
  
  static var clear: BatchOperation {
    return .init(action: .clear)
  }

  
}

public extension BatchOperation {

  enum Action: String, Codable {
    case addObject
    case updateObject
    case partialUpdateObject
    case partialUpdateObjectNoCreate
    case deleteObject
    case delete
    case clear
  }

}
