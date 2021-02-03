//
//  DictionaryRequest.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

enum DictionaryRequest<Entry: DictionaryEntry> {

  enum Action: String, Codable {
    case addEntry
    case deleteEntry
  }

  case addEntry(Entry)
  case deleteEntry(withObjectID: ObjectID)

  static func add(_ entry: Entry) -> Self {
    return .addEntry(entry)
  }

  static func delete<D: CustomDictionary>(dictionary: D.Type, objectID: ObjectID) -> DictionaryRequest<D.Entry> {
    return .deleteEntry(withObjectID: objectID)
  }

  enum CodingKeys: String, CodingKey {
    case action
    case body
  }

}

extension DictionaryRequest: Encodable where Entry: Encodable {

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .addEntry(let entry):
      try container.encode(Action.addEntry, forKey: .action)
      try container.encode(entry, forKey: .body)
    case .deleteEntry(let objectID):
      try container.encode(Action.deleteEntry, forKey: .action)
      try container.encode(ObjectIDWrapper(objectID), forKey: .body)
    }
  }

}

extension DictionaryRequest: Decodable where Entry: Decodable {

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let action = try container.decode(Action.self, forKey: .action)
    switch action {
    case .addEntry:
      let entry = try container.decode(Entry.self, forKey: .body)
      self = .addEntry(entry)

    case .deleteEntry:
      let objectID = try container.decode(ObjectIDWrapper.self, forKey: .body).wrapped
      self = .deleteEntry(withObjectID: objectID)
    }
  }

}
