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

extension BatchOperation {
  
  public static func with(_ action: Action) -> (T) -> BatchOperation {
    return { body in
      BatchOperation(action: action, body: body)
    }
  }
  
}

extension BatchOperation where T == JSON {
  
  public init(action: Action, body: [String: Any]) throws {
    self.action = action
    self.body = try JSON(jsonObject: body)
  }
  
  public static func with(_ action: Action) -> ([String: Any]) throws -> BatchOperation<JSON> {
    return { body in
      try BatchOperation(action: action, body: body)
    }
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
