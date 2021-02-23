//
//  PlacesPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

struct PlacesCompletion: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var query: Self { .init(#function) }
  static func objectID(_ objectID: ObjectID) -> Self { .init(objectID.rawValue) }
  static var reverse: Self { .init(#function) }

}
