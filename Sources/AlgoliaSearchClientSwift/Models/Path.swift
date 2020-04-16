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

    set {
    }
  }

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var indexesV1: Self { .init("/1/indexes") }
  static var settings: Self { .init("/settings") }
  static var clustersV1: Self { .init("/1/clusters") }
  static var synonyms: Self { .init("/synonyms") }
  static var eventsV1: Self { .init("/1/events") }
  static var ABTestsV2: Self { .init("/2/abtests") }
  static var rules: Self { .init("/rules") }
  static var keysV1: Self { .init("/1/keys") }
  static var logs: Self { .init("/1/logs") }
  static var recommendation: Self { .init("/1/recommendation") }
  static var places: Self { .init("/1/places") }
  static var task: Self { .init("/task") }

}

struct IndexRoute: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func index(_ indexName: IndexName) -> Self {
    return .init(indexName.rawValue)
  }

  static var multiIndex: Self { .init("*") }

}

struct IndexCompletion: PathComponent {

  var parent: IndexRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var batch: Self { .init(#function) }
  static var operation: Self { .init(#function) }
  static func objectID(_ objectID: ObjectID, partial: Bool = false) -> Self { .init(objectID.rawValue + (partial ? "/partial" : "")) }
  static var objects: Self { .init("*/objects") }
  static var deleteByQuery: Self { .init(#function) }
  static var clear: Self { .init(#function) }
  static var query: Self { .init(#function) }
  static var browse: Self { .init(#function) }
  static func searchFacets(for attribute: Attribute) -> Self { .init("facets/\(attribute.rawValue)/query") }
  static var settings: Self { .init(#function) }
  static func task(for taskID: TaskID) -> Self { .init("task/\(taskID.rawValue)") }

}

struct MultiIndexCompletion: PathComponent {

  var parent: IndexRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var keys: Self { .init(#function) }
  static var batch: Self { .init(#function) }
  static var logs: Self { .init(#function) }
  static var queries: Self { .init(#function) }
  static var objects: Self { .init(#function) }

}

struct APIKeyCompletion: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func apiKey(_ value: APIKey) -> Self { .init(value.rawValue) }
  static func restoreAPIKey(_ value: APIKey) -> Self { .init("\(value.rawValue)/restore")}
}

struct PlacesCompletion: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var query: Self { .init(#function) }
  static func objectID(_ objectID: ObjectID) -> Self { .init(objectID.rawValue) }
  static var reverse: Self { .init(#function) }

}
