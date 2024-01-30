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
  public init(action: Action, bodyObject: some Encodable) {
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

extension BatchOperation {
  public static func add(_ object: some Encodable, autoGeneratingObjectID: Bool = false) -> Self {
    if !autoGeneratingObjectID {
      do {
        try ObjectIDChecker.checkObjectID(object)
      } catch {
        assertionFailure("\(error.localizedDescription)")
      }
    }

    return .init(action: .addObject, bodyObject: object)
  }

  public static func update(objectID: ObjectID, _ object: some Encodable) -> Self {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(action: .updateObject, bodyObject: objectWrapper)
  }

  public static func partialUpdate(
    objectID: ObjectID, _ object: some Encodable, createIfNotExists: Bool
  ) -> Self {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: object)
    return .init(
      action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate,
      bodyObject: objectWrapper)
  }

  public static func partialUpdate(
    objectID: ObjectID, partialUpdate: PartialUpdate, createIfNotExists: Bool
  ) -> Self {
    let objectWrapper = ObjectWrapper(objectID: objectID, object: partialUpdate)
    return .init(
      action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate,
      bodyObject: objectWrapper)
  }

  public static func delete(objectID: ObjectID) -> Self {
    .init(action: .deleteObject, bodyObject: ObjectWrapper(objectID: objectID))
  }

  public static var delete: Self { .init(action: .delete) }

  public static var clear: Self { .init(action: .clear) }
}

extension BatchOperation {
  public enum Action: String, Codable {
    case addObject
    case updateObject
    case partialUpdateObject
    case partialUpdateObjectNoCreate
    case deleteObject
    case delete
    case clear
  }
}
