//
//  TestRecord.swift
//
//
//  Created by Vladislav Fitc on 21/04/2020.
//

import Foundation

@testable import AlgoliaSearchClient

struct TestRecord: Codable, Equatable, CustomStringConvertible {
  var objectID: ObjectID?
  var string: String
  var numeric: Int
  var bool: Bool
  var _tags: [String]?

  init(objectID: String) {
    self.init(objectID: .init(rawValue: objectID))
  }

  init(objectID: ObjectID? = nil) {
    self.objectID = objectID
    string = .random(length: .random(in: 1..<100))
    numeric = .random(in: 1..<100)
    bool = .random()
  }

  var description: String {
    [
      objectID.flatMap { "objectID: \($0)" }, "string: \(string)", "numeric: \(numeric)",
      "bool: \(bool)", _tags.flatMap { "tags: \($0)" },
    ].compactMap { $0 }.joined(separator: ", ")
  }
}

extension TestRecord: Builder {}
