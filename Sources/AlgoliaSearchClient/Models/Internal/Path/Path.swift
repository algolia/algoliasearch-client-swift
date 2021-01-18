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

  private init(_ rawValue: String) { self.rawValue = rawValue }

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
  static var task: Self { .init("/task") }
  static var answers: Self { .init("/1/answers") }

}

struct IndexRoute: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func index(_ indexName: IndexName) -> Self { .init(indexName.rawValue) }

  static var multiIndex: Self { .init("*") }

}

struct IndexCompletion: PathComponent {

  var parent: IndexRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var batch: Self { .init(#function) }
  static var operation: Self { .init(#function) }
  static func objectID(_ objectID: ObjectID, partial: Bool = false) -> Self { .init(objectID.rawValue + (partial ? "/partial" : "")) }
  static var deleteByQuery: Self { .init(#function) }
  static var clear: Self { .init(#function) }
  static var query: Self { .init(#function) }
  static var browse: Self { .init(#function) }
  static func searchFacets(for attribute: Attribute) -> Self { .init("facets/\(attribute.rawValue)/query") }
  static var settings: Self { .init(#function) }
  static func task(for taskID: TaskID) -> Self { .init("task/\(taskID.rawValue)") }
  static var rules: Self { .init(#function) }
  static var synonyms: Self { .init(#function) }
  static var prediction: Self { .init(#function) }

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

struct RuleCompletion: PathComponent {

  var parent: IndexCompletion?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func objectID(_ objectID: ObjectID) -> Self { .init(objectID.rawValue) }
  static var search: Self { .init(#function) }
  static var clear: Self { .init(#function) }
  static var batch: Self { .init(#function) }

}

struct SynonymCompletion: PathComponent {

  var parent: IndexCompletion?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func objectID(_ objectID: ObjectID) -> Self { .init(objectID.rawValue) }
  static var search: Self { .init(#function) }
  static var clear: Self { .init(#function) }
  static var batch: Self { .init(#function) }

}

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

struct ABTestRoute: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func ABTestID(_ abTestID: ABTestID) -> Self { .init(abTestID.rawValue) }

}

struct ABTestCompletion: PathComponent {

  var parent: ABTestRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var stop: Self { .init(#function) }

}
