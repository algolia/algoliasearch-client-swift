//
//  Rule+Edit.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

extension Rule {

  public enum Edit: Equatable {

    /// Text or patterns to remove from the Query.query.
    case remove(String)

    /// Text that should be inserted in place of the removed text inside the Query.query.
    case replace(String, with: String)

  }

}

extension Rule.Edit: Codable {

  enum CodingKeys: String, CodingKey {
    case delete, insert, type
  }

  enum EditType: String, Codable {
    case replace, remove
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type: EditType = try container.decode(forKey: .type)
    let delete: String = try container.decode(forKey: .delete)
    switch type {
    case .remove:
      self = .remove(delete)
    case .replace:
      let insert: String = try container.decode(forKey: .insert)
      self = .replace(delete, with: insert)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .remove(let delete):
      try container.encode(EditType.remove, forKey: .type)
      try container.encode(delete, forKey: .delete)
    case .replace(let delete, let insert):
      try container.encode(EditType.replace, forKey: .type)
      try container.encode(delete, forKey: .delete)
      try container.encode(insert, forKey: .insert)
    }
  }

}
