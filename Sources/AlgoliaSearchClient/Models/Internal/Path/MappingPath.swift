//
//  MappingPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

struct MappingRoute: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var mapping: Self { .init(#function) }

}

struct MappingCompletion: PathComponent {

  var parent: MappingRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func userID(_ userID: UserID) -> Self { .init(userID.rawValue) }

  static var top: Self { .init(#function) }
  static var search: Self { .init(#function) }
  static var batch: Self { .init(#function) }
  static var pending: Self { .init(#function) }

}
