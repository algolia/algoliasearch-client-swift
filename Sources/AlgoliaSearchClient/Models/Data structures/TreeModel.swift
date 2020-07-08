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
    case let .value(value):
      try container.encode(value)
    case let .array(array):
      try container.encode(array)
    case let .dictionary(dictionary):
      try container.encode(dictionary)
    }

  }

}

extension TreeModel: Equatable where T: Equatable {}

public extension TreeModel {

  var value: T? {
    guard case let .value(value) = self else {
      return nil
    }
    return value
  }

  func value(atIndex index: Int) -> Self? {
    guard case let .array(array) = self else {
      return nil
    }
    return array[index]
  }

  func value(forKey key: String) -> Self? {
    guard case let .dictionary(dictionary) = self else {
      return nil
    }
    return dictionary[key]
  }

  subscript(index: Int) -> Self? {
    return value(atIndex: index)
  }

  subscript(key: String) -> Self? {
    return value(forKey: key)
  }

}
