//
//  PartialUpdateAction.swift
//  
//
//  Created by Vladislav Fitc on 01/08/2020.
//

import Foundation

extension PartialUpdate {

  public struct Action: Equatable {
    let storage: Storage
  }
}

extension PartialUpdate.Action {

  enum Storage: Codable, Equatable {

    case set(JSON)
    case operation(PartialUpdate.Operation)

    public init(from decoder: Decoder) throws {
      if let operation = try? PartialUpdate.Operation(from: decoder) {
        self = .operation(operation)
      } else {
        self = .set(try JSON(from: decoder))
      }
    }

    public func encode(to encoder: Encoder) throws {
      switch self {
      case .set(let value):
        try value.encode(to: encoder)
      case .operation(let operation):
        try operation.encode(to: encoder)
      }
    }

  }

}

extension PartialUpdate.Action: Decodable {

  public init(from decoder: Decoder) throws {
    self.storage = try Storage(from: decoder)
  }

}

extension PartialUpdate.Action: Encodable {

  public func encode(to encoder: Encoder) throws {
    try storage.encode(to: encoder)
  }

}

public extension PartialUpdate.Action {

  init(_ json: JSON) {
    storage = .set(json)
  }

  static func set(_ json: JSON) -> Self {
    return .init(json)
  }

}

extension PartialUpdate.Action: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    storage = .set(.string(value))
  }

}

extension PartialUpdate.Action: ExpressibleByFloatLiteral {

  public init(floatLiteral value: Double) {
    storage = .set(.number(value))
  }

}

extension PartialUpdate.Action: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: Int) {
    storage = .set(.number(Double(value)))
  }

}

extension PartialUpdate.Action: ExpressibleByBooleanLiteral {

  public init(booleanLiteral value: Bool) {
    storage = .set(.bool(value))
  }

}

extension PartialUpdate.Action: ExpressibleByDictionaryLiteral {

  public init(dictionaryLiteral elements: (String, JSON)...) {
    storage = .set(.dictionary(.init(uniqueKeysWithValues: elements)))
  }

}

extension PartialUpdate.Action: ExpressibleByArrayLiteral {

  public init(arrayLiteral elements: JSON...) {
    storage = .set(.array(elements))
  }

}

extension PartialUpdate.Action: ExpressibleByNilLiteral {

  public init(nilLiteral: ()) {
    storage = .set(.null)
  }

}

extension PartialUpdate.Action {

  init(operation: PartialUpdate.Operation.Kind, value: JSON) {
    storage = .operation(.init(kind: operation, value: value))
  }

}

public extension PartialUpdate.Action {

  /// Increment a numeric attribute
  /// - Parameter value: Value to increment by
  static func increment(value: Int) -> Self {
    .init(operation: .increment, value: .init(value))
  }

  /// Increment a numeric attribute
  /// - Parameter value: Value to increment by
  static func increment(value: Float) -> Self {
    .init(operation: .increment, value: .init(value))
  }

  /// Increment a numeric attribute
  /// - Parameter value: Value to increment by
  static func increment(attribute: Attribute, value: Double) -> Self {
    .init(operation: .increment, value: .init(value))
  }

}

public extension PartialUpdate.Action {

  /**
   Increment a numeric integer attribute only if the provided value matches the current value,
   and otherwise ignore the whole object update.
   
   For example, if you pass an IncrementFrom value of 2 for the version attribute,
   but the current value of the attribute is 1, the engine ignores the update.
   If the object doesn’t exist, the engine only creates it if you pass an IncrementFrom value of 0.
   
   - Parameter value: Current value to increment
   */
  static func incrementFrom(value: Int) -> Self {
    .init(operation: .incrementFrom, value: .init(value))
  }

  /**
   Increment a numeric integer attribute only if the provided value is greater than the current value,
   and otherwise ignore the whole object update.
   
   For example, if you pass an IncrementSet value of 2 for the version attribute,
   and the current value of the attribute is 1, the engine updates the object.
   If the object doesn’t exist yet, the engine only creates it if you pass an IncrementSet value that’s greater than 0.
   
   - Parameter value: Value to set
   */
  static func incrementSet(value: Int) -> Self {
    .init(operation: .incrementSet, value: .init(value))
  }

}

public extension PartialUpdate.Action {

  /// Decrement a numeric attribute
  /// - Parameter value: Value to decrement by
  static func decrement(value: Int) -> Self {
    .init(operation: .decrement, value: .init(value))
  }

  /// Decrement a numeric attribute
  /// - Parameter value: Value to decrement by
  static func decrement(value: Float) -> Self {
    .init(operation: .decrement, value: .init(value))
  }

  /// Decrement a numeric attribute
  /// - Parameter value: Value to decrement by
  static func decrement(value: Double) -> Self {
    .init(operation: .decrement, value: .init(value))
  }

}

public extension PartialUpdate.Action {

  /// Append a string element to an array attribute
  /// - Parameter value: Value to append
  /// - Parameter unique: If true, append an element only if it’s not already present
  static func add(value: String, unique: Bool) -> Self {
    .init(operation: unique ? .addUnique : .add, value: .init(value))
  }

  /// Append a number element to an array attribute
  /// - Parameter value: Value to append
  /// - Parameter unique: If true, append an element only if it’s not already present
  static func add(value: Int, unique: Bool) -> Self {
    .init(operation: unique ? .addUnique : .add, value: .init(value))
  }

  /// Append a number element to an array attribute
  /// - Parameter value: Value to append
  /// - Parameter unique: If true, append an element only if it’s not already present
  static func add(value: Float, unique: Bool) -> Self {
    .init(operation: unique ? .addUnique : .add, value: .init(value))
  }

  /// Append a number element to an array attribute
  /// - Parameter value: Value to append
  /// - Parameter unique: If true, append an element only if it’s not already present
  static func add(value: Double, unique: Bool) -> Self {
    .init(operation: unique ? .addUnique : .add, value: .init(value))
  }

}

public extension PartialUpdate.Action {

  /// Remove all matching string elements from an array attribute
  /// - Parameter value: Value to remove
  static func remove(value: String) -> Self {
    .init(operation: .remove, value: .init(value))
  }

  /// Remove all matching number elements from an array attribute
  /// - Parameter value: Value to remove
  static func remove(attribute: Attribute, value: Int) -> Self {
    .init(operation: .remove, value: .init(value))
  }

  /// Remove all matching number elements from an array attribute
  /// - Parameter value: Value to remove
  static func remove(value: Float) -> Self {
    .init(operation: .remove, value: .init(value))
  }

  /// Remove all matching number elements from an array attribute
  /// - Parameter value: Value to remove
  static func remove(value: Double) -> Self {
    .init(operation: .remove, value: .init(value))
  }

}
