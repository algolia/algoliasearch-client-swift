//
//  PartialUpdate.swift
//  
//
//  Created by Vladislav Fitc on 27/03/2020.
//

import Foundation

public struct PartialUpdate: Equatable {

  let attribute: Attribute
  let content: PartialUpdate.Content

}

public extension PartialUpdate {

  static func update(attribute: Attribute, value: JSON) -> Self {
    .init(attribute: attribute, content: .init(value: value, operation: nil))
  }

}

public extension PartialUpdate {

  static func increment(attribute: Attribute, value: Int) -> Self {
    .operation(attribute: attribute, operation: .increment, value: .init(value))
  }

  static func increment(attribute: Attribute, value: Float) -> Self {
    .operation(attribute: attribute, operation: .increment, value: .init(value))
  }

  static func increment(attribute: Attribute, value: Double) -> Self {
    .operation(attribute: attribute, operation: .increment, value: .init(value))
  }

}

public extension PartialUpdate {

  static func decrement(attribute: Attribute, value: Int) -> Self {
    .operation(attribute: attribute, operation: .decrement, value: .init(value))
  }

  static func decrement(attribute: Attribute, value: Float) -> Self {
    .operation(attribute: attribute, operation: .decrement, value: .init(value))
  }

  static func decrement(attribute: Attribute, value: Double) -> Self {
    .operation(attribute: attribute, operation: .decrement, value: .init(value))
  }

}

public extension PartialUpdate {

  static func add(attribute: Attribute, value: String, unique: Bool) -> Self {
    .operation(attribute: attribute, operation: unique ? .addUnique : .add, value: .init(value))
  }

  static func add(attribute: Attribute, value: Int, unique: Bool) -> Self {
    .operation(attribute: attribute, operation: unique ? .addUnique : .add, value: .init(value))
  }

  static func add(attribute: Attribute, value: Float, unique: Bool) -> Self {
    .operation(attribute: attribute, operation: unique ? .addUnique : .add, value: .init(value))
  }

  static func add(attribute: Attribute, value: Double, unique: Bool) -> Self {
    .operation(attribute: attribute, operation: unique ? .addUnique : .add, value: .init(value))
  }

}

public extension PartialUpdate {

  static func remove(attribute: Attribute, value: String) -> Self {
    .operation(attribute: attribute, operation: .remove, value: .init(value))
  }

  static func remove(attribute: Attribute, value: Int) -> Self {
    .operation(attribute: attribute, operation: .remove, value: .init(value))
  }

  static func remove(attribute: Attribute, value: Float) -> Self {
    .operation(attribute: attribute, operation: .remove, value: .init(value))
  }

  static func remove(attribute: Attribute, value: Double) -> Self {
    .operation(attribute: attribute, operation: .remove, value: .init(value))
  }

}

extension PartialUpdate {

  static func operation(attribute: Attribute, operation: PartialUpdate.Operation, value: JSON) -> Self {
    .init(attribute: attribute, content: .init(value: value, operation: operation))
  }

}

extension PartialUpdate: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKey.self)
    guard let rawAttribute = container.allKeys.first else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No attribute found")) }
    self.attribute = Attribute(rawValue: rawAttribute.stringValue)
    self.content = try container.decode(PartialUpdate.Content.self, forKey: rawAttribute)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DynamicKey.self)
    let key = DynamicKey(stringValue: attribute.rawValue)
    try container.encode(content, forKey: key)
  }

}

extension PartialUpdate {

  enum Operation: String, Codable {
    case increment = "Increment"
    case decrement = "Decrement"
    case add = "Add"
    case remove = "Remove"
    case addUnique = "AddUnique"
  }

}

extension PartialUpdate {

  struct Content: Equatable {
    let value: JSON
    let operation: Operation?
  }

}

extension PartialUpdate.Content: Codable {

  enum CodingKeys: String, CodingKey {
    case value
    case operation = "_operation"
  }

  public init(from decoder: Decoder) throws {
    guard let container = try? decoder.container(keyedBy: CodingKeys.self), container.contains(.operation) else {
      self.operation = nil
      self.value = try JSON(from: decoder)
      return
    }
    self.operation = try container.decode(forKey: .operation)
    self.value = try container.decode(forKey: .value)
  }

  public func encode(to encoder: Encoder) throws {
    if let operation = operation {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(operation, forKey: .operation)
      try container.encode(value, forKey: .value)
    } else {
      try value.encode(to: encoder)
    }

  }

}
