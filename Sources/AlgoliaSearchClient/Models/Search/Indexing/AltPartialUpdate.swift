//
//  AltPartialUpdate.swift
//  
//
//  Created by Vladislav Fitc on 31/07/2020.
//

import Foundation

public enum AltPartialUpdate {
  case value([String: JSON])
  case operation(Attribute, OperationWrapper)
}

extension AltPartialUpdate: Codable {
  
  public init(from decoder: Decoder) throws {
    self = .value(["": ""])
  }
  
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .value(let value):
      try value.encode(to: encoder)
      
    case .operation(let attribute, let operation):
      var container = encoder.container(keyedBy: DynamicKey.self)
      let key = DynamicKey(stringValue: attribute.rawValue)
      try container.encode(operation, forKey: key)
    }
  }
  
  public struct OperationWrapper: Codable {
    let value: JSON
    let operation: Operation

    enum CodingKeys: String, CodingKey {
      case value
      case operation = "_operation"
    }
  }
  
}

extension AltPartialUpdate {
  
  /// Partially update an object field.
  /// - Parameter attribute: Attribute name to update
  /// - Parameter value: Updated value
  static func update(attribute: Attribute, value: JSON) -> Self {
    return .value([attribute.rawValue: value])
  }
  
}

public extension AltPartialUpdate {
  
  /// Increment a numeric attribute
  /// - Parameter attribute: Attribute name to update
  /// - Parameter value: Value to increment by
  static func increment(attribute: Attribute, value: Int) -> Self {
    .operation(attribute: attribute, operation: .increment, value: .init(value))
  }

  /// Increment a numeric attribute
  /// - Parameter attribute: Attribute name to update
  /// - Parameter value: Value to increment by
  static func increment(attribute: Attribute, value: Float) -> Self {
    .operation(attribute: attribute, operation: .increment, value: .init(value))
  }

  /// Increment a numeric attribute
  /// - Parameter attribute: Attribute name to update
  /// - Parameter value: Value to increment by
  static func increment(attribute: Attribute, value: Double) -> Self {
    .operation(attribute: attribute, operation: .increment, value: .init(value))
  }

}

public extension AltPartialUpdate {

  /**
   Increment a numeric integer attribute only if the provided value matches the current value,
   and otherwise ignore the whole object update.
   
   For example, if you pass an IncrementFrom value of 2 for the version attribute,
   but the current value of the attribute is 1, the engine ignores the update.
   If the object doesn’t exist, the engine only creates it if you pass an IncrementFrom value of 0.
   
   - Parameter attribute: Attribute name to update
   - Parameter value: Current value to increment
   */
  static func incrementFrom(attribute: Attribute, value: Int) -> Self {
    .operation(attribute: attribute, operation: .incrementFrom, value: .init(value))
  }
  
  /**
   Increment a numeric integer attribute only if the provided value is greater than the current value,
   and otherwise ignore the whole object update.
   
   For example, if you pass an IncrementSet value of 2 for the version attribute,
   and the current value of the attribute is 1, the engine updates the object.
   If the object doesn’t exist yet, the engine only creates it if you pass an IncrementSet value that’s greater than 0.
   
   - Parameter attribute: Attribute name to update
   - Parameter value: Value to set
   */
  static func incrementSet(attribute: Attribute, value: Int) -> Self {
    .operation(attribute: attribute, operation: .incrementSet, value: .init(value))
  }

}


public extension AltPartialUpdate {

  /// Decrement a numeric attribute
  /// - Parameter attribute: Attribute name to update
  /// - Parameter value: Value to decrement by
  static func decrement(attribute: Attribute, value: Int) -> Self {
    .operation(attribute: attribute, operation: .decrement, value: .init(value))
  }
  
  /// Decrement a numeric attribute
  /// - Parameter attribute: Attribute name to update
  /// - Parameter value: Value to decrement by
  static func decrement(attribute: Attribute, value: Float) -> Self {
    .operation(attribute: attribute, operation: .decrement, value: .init(value))
  }

  /// Decrement a numeric attribute
  /// - Parameter attribute: Attribute name to update
  /// - Parameter value: Value to decrement by
  static func decrement(attribute: Attribute, value: Double) -> Self {
    .operation(attribute: attribute, operation: .decrement, value: .init(value))
  }

}

public extension AltPartialUpdate {

  /// Append a string element to an array attribute
  /// - Parameter attribute: Attribute name of an array to update
  /// - Parameter value: Value to append
  /// - Parameter unique: If true, append an element only if it’s not already present
  static func add(attribute: Attribute, value: String, unique: Bool) -> Self {
    .operation(attribute: attribute, operation: unique ? .addUnique : .add, value: .init(value))
  }

  /// Append a number element to an array attribute
  /// - Parameter attribute: Attribute name of an array to update
  /// - Parameter value: Value to append
  /// - Parameter unique: If true, append an element only if it’s not already present
  static func add(attribute: Attribute, value: Int, unique: Bool) -> Self {
    .operation(attribute: attribute, operation: unique ? .addUnique : .add, value: .init(value))
  }

  /// Append a number element to an array attribute
  /// - Parameter attribute: Attribute name of an array to update
  /// - Parameter value: Value to append
  /// - Parameter unique: If true, append an element only if it’s not already present
  static func add(attribute: Attribute, value: Float, unique: Bool) -> Self {
    .operation(attribute: attribute, operation: unique ? .addUnique : .add, value: .init(value))
  }

  /// Append a number element to an array attribute
  /// - Parameter attribute: Attribute name of an array to update
  /// - Parameter value: Value to append
  /// - Parameter unique: If true, append an element only if it’s not already present
  static func add(attribute: Attribute, value: Double, unique: Bool) -> Self {
    .operation(attribute: attribute, operation: unique ? .addUnique : .add, value: .init(value))
  }

}

public extension AltPartialUpdate {

  /// Remove all matching string elements from an array attribute
  /// - Parameter attribute: Attribute name of an array to update
  /// - Parameter value: Value to remove
  static func remove(attribute: Attribute, value: String) -> Self {
    .operation(attribute: attribute, operation: .remove, value: .init(value))
  }

  /// Remove all matching number elements from an array attribute
  /// - Parameter attribute: Attribute name of an array to update
  /// - Parameter value: Value to remove
  static func remove(attribute: Attribute, value: Int) -> Self {
    .operation(attribute: attribute, operation: .remove, value: .init(value))
  }

  /// Remove all matching number elements from an array attribute
  /// - Parameter attribute: Attribute name of an array to update
  /// - Parameter value: Value to remove
  static func remove(attribute: Attribute, value: Float) -> Self {
    .operation(attribute: attribute, operation: .remove, value: .init(value))
  }

  /// Remove all matching number elements from an array attribute
  /// - Parameter attribute: Attribute name of an array to update
  /// - Parameter value: Value to remove
  static func remove(attribute: Attribute, value: Double) -> Self {
    .operation(attribute: attribute, operation: .remove, value: .init(value))
  }

}

extension AltPartialUpdate {

  static func operation(attribute: Attribute, operation: Operation, value: JSON) -> Self {
    return .operation(attribute, .init(value: value, operation: operation))
  }

}

extension AltPartialUpdate {

  enum Operation: String, Codable {
    /// Increment a numeric attribute
    case increment = "Increment"
    
    /**
     Increment a numeric integer attribute only if the provided value matches the current value,
     and otherwise ignore the whole object update.
     
     For example, if you pass an IncrementFrom value of 2 for the version attribute,
     but the current value of the attribute is 1, the engine ignores the update.
     If the object doesn’t exist, the engine only creates it if you pass an IncrementFrom value of 0.
     */
    case incrementFrom = "IncrementFrom"
    
    /**
     Increment a numeric integer attribute only if the provided value is greater than the current value,
     and otherwise ignore the whole object update.
     
     For example, if you pass an IncrementSet value of 2 for the version attribute,
     and the current value of the attribute is 1, the engine updates the object.
     If the object doesn’t exist yet, the engine only creates it if you pass an IncrementSet value that’s greater than 0.
     */
    case incrementSet = "IncrementSet"
    
    /// Decrement a numeric attribute
    case decrement = "Decrement"
    
    /// Append a number or string element to an array attribute
    case add = "Add"
    
    /// Remove all matching number or string elements from an array attribute
    case remove = "Remove"
    
    /// Add a number or string element to an array attribute only if it’s not already present
    case addUnique = "AddUnique"
  }

}
