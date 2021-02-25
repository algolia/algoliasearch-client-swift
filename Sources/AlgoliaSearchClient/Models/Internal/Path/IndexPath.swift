//
//  IndexPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

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
