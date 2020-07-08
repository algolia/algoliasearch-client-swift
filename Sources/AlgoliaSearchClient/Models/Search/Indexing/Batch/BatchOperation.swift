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

  public init<T: Encodable>(action: Action, bodyObject: T) {
    guard let body = try? JSON(bodyObject) else {
      assertionFailure("Cannot create JSON with provided object")
      self.init(action: action)
      return
    }
    self.init(action: action, body: body)
  }

  public init(action: Action) {
    self.init(action: action, body: nil)
  }

}

public extension BatchOperation {

  static func add<T: Encodable>(_ object: T, autoGeneratingObjectID: Bool = false) -> Self {
    if !autoGeneratingObjectID {
      do {
        try ObjectIDChecker.checkObjectID(object)
      } catch let error {
        assertionFailure("\(error.localizedDescription)")
      }
    }

    return .init(action: .addObject, bodyObject: object)
  }

  static func update<T: Encodable>(objectID: ObjectID, _ object: T) -> Self {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: .updateObject, bodyObject: objectWrapper)
  }

  static func partialUpdate<T: Encodable>(objectID: ObjectID, _ object: T, createIfNotExists: Bool) -> Self {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate, bodyObject: objectWrapper)
  }

  static func partialUpdate(objectID: ObjectID, partialUpdate: PartialUpdate, createIfNotExists: Bool) -> Self {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: partialUpdate)
    return .init(action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate, bodyObject: objectWrapper)
  }

  static func delete(objectID: ObjectID) -> Self {
    .init(action: .deleteObject, bodyObject: ObjectWrapper(objectID: objectID))
  }

  static var delete: Self { .init(action: .delete) }

  static var clear: Self { .init(action: .clear) }

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
