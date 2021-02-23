//
//  SynonymPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

struct SynonymCompletion: PathComponent {

  var parent: IndexCompletion?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func objectID(_ objectID: ObjectID) -> Self { .init(objectID.rawValue) }
  static var search: Self { .init(#function) }
  static var clear: Self { .init(#function) }
  static var batch: Self { .init(#function) }

}
