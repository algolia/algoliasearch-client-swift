//
//  Route.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

struct Path: PathComponent {

  typealias Parent = Never

  let rawValue: String
  var parent: Never? {
    get {
      return nil
    }
    // swiftlint:disable:next unused_setter_value
    set {
    }
  }

  init(_ rawValue: String) { self.rawValue = rawValue }

  static var indexesV1: Self { .init("/1/indexes") }
  static var settings: Self { .init("/settings") }
  static var clustersV1: Self { .init("/1/clusters") }
  static var synonyms: Self { .init("/synonyms") }
  static var eventsV1: Self { .init("/1/events") }
  static var ABTestsV2: Self { .init("/2/abtests") }
  static var keysV1: Self { .init("/1/keys") }
  static var logs: Self { .init("/1/logs") }
  static var strategies: Self { .init("/1/strategies") }
  static var places: Self { .init("/1/places") }
  static var answers: Self { .init("/1/answers") }
  static var dictionaries: Self { .init("/1/dictionaries") }
  static var task: Self { .init("/1/task") }
}
