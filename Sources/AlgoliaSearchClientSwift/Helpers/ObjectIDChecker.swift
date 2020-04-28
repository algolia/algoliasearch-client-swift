//
//  ObjectIDChecker.swift
//  
//
//  Created by Vladislav Fitc on 28/04/2020.
//

import Foundation

struct ObjectIDChecker {
  
  static func checkObjectID<T: Encodable>(_ object: T) throws {
    guard case .dictionary(let dictionary) = object as? JSON ?? (try? JSON(object)), dictionary.keys.contains("objectID") else {
      throw Error.missingObjectIDProperty
    }
  }
  
  enum Error: Swift.Error {
    case missingObjectIDProperty
  }
  
}
