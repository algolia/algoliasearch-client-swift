//
//  TreeModel.swift
//
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation

public indirect enum TreeModel<T: Codable>: Codable {
  case value(T)
  case array([TreeModel])
  case dictionary([String: TreeModel])

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let dictionary = try? container.decode([String: TreeModel].self) {
      self = .dictionary(dictionary)
    } else if let array = try? container.decode([TreeModel].self) {
      self = .array(array)
    } else if let value = try? container.decode(T.self) {
      self = .value(value)
    } else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath, debugDescription: "Invalid value")
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .value(let value):
      try container.encode(value)
    case .array(let array):
      try container.encode(array)
    case .dictionary(let dictionary):
      try container.encode(dictionary)
    }
  }
}

extension TreeModel: Equatable where T: Equatable {}

extension TreeModel {
  public var value: T? {
    guard case .value(let value) = self else {
      return nil
    }
    return value
  }

  public func value(atIndex index: Int) -> Self? {
    guard case .array(let array) = self else {
      return nil
    }
    return array[index]
  }

  public func value(forKey key: String) -> Self? {
    guard case .dictionary(let dictionary) = self else {
      return nil
    }
    return dictionary[key]
  }

  public subscript(index: Int) -> Self? {
    value(atIndex: index)
  }

  public subscript(key: String) -> Self? {
    value(forKey: key)
  }
}
