//
//  PersonalizationPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

struct PersonalizationRoute: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var personalization: Self { .init(#function) }

}

struct PersonalizationCompletion: PathComponent {

  var parent: PersonalizationRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var strategy: Self { .init(#function) }

}
