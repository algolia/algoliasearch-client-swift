//
//  ObjectIDChecker.swift
//  
//
//  Created by Vladislav Fitc on 28/04/2020.
//

import Foundation

struct ObjectIDChecker {

  static func checkObjectID<T: Encodable>(_ object: T) throws {
    let data = try JSONEncoder().encode(object)
    do {
      _ = try JSONDecoder().decode(ObjectWrapper<Empty>.self, from: data)
    } catch _ {
      throw Error.missingObjectIDProperty
    }
  }

  static func assertObjectID<T: Encodable>(_ object: T) {
    do {
      try checkObjectID(object)
    } catch let error {
      assertionFailure("\(error.localizedDescription)")
    }
  }

  enum Error: Swift.Error {
    case missingObjectIDProperty

    var localizedDescription: String {
      switch self {
      case .missingObjectIDProperty:
        return "Object must contain encoded `objectID` field if autoGenerationObjectID is set to false"
      }
    }
  }

}
