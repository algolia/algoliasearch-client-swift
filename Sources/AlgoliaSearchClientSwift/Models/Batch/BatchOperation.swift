//
//  BatchOperation.swift
//  
//
//  Created by Vladislav Fitc on 18/03/2020.
//

import Foundation

public struct BatchOperation: Codable, Equatable {

  public let action: Action
  public let body: JSON
  
}

extension BatchOperation {
  
  init<T: Encodable>(action: Action, body: T) {
    let body = try! JSON(body)
    self.init(action: action, body: body)
  }
  
}

extension BatchOperation {
    
  static func add<T: Encodable>(_ object: T) -> BatchOperation {
    return .init(action: .addObject, body: object)
  }
    
  static func update<T: Codable>(objectID: ObjectID, _ object: T) -> BatchOperation {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: .updateObject, body: objectWrapper)
  }
  
  static func partialUpdate<T: Codable>(objectID: ObjectID, _ object: T, createIfNotExists: Bool) -> BatchOperation {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate, body: objectWrapper)
  }
  
  static func partialUpdate(objectID: ObjectID, partialUpdate: PartialUpdate, createIfNotExists: Bool) -> BatchOperation {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: partialUpdate)
    return .init(action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate, body: objectWrapper)
  }

  static func delete(objectID: ObjectID) -> BatchOperation {
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
