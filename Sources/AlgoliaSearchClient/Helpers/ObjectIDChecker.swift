//
//  ObjectIDChecker.swift
//
//
//  Created by Vladislav Fitc on 28/04/2020.
//

import Foundation

public enum ObjectIDChecker {
  static func checkObjectID(_ object: some Encodable) throws {
    let data = try JSONEncoder().encode(object)
    do {
      _ = try JSONDecoder().decode(ObjectWrapper<Empty>.self, from: data)
    } catch _ {
      throw Error.missingObjectIDProperty
    }
  }

  static func assertObjectID(_ object: some Encodable) {
    do {
      try checkObjectID(object)
    } catch {
      assertionFailure("\(error.localizedDescription)")
    }
  }

  public enum Error: Swift.Error {
    case missingObjectIDProperty

    var localizedDescription: String {
      switch self {
      case .missingObjectIDProperty:
        return
          "Object must contain encoded `objectID` field if autoGenerationObjectID is set to false"
      }
    }
  }
}
