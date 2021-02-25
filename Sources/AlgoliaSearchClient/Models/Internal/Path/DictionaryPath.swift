//
//  DictionaryPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

struct DictionaryRoute: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func dictionaryName(_ dictionaryName: DictionaryName) -> Self { .init(dictionaryName.rawValue) }

  static var common: Self { .init("*") }

}

struct DictionaryCompletion: PathComponent {

  var parent: DictionaryRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var batch: Self { .init(#function) }
  static var search: Self { .init(#function) }
  static var settings: Self { .init(#function) }
  static var languages: Self { .init(#function) }

}
