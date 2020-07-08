//
//  CustomKey.swift
//  
//
//  Created by Vladislav Fitc on 13/04/2020.
//

import Foundation

@propertyWrapper
public struct CustomKey<Key: Hashable & RawRepresentable, Value: Codable>: Codable where Key.RawValue == String {

  public var wrappedValue: [Key: Value]

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKey.self)
    var storage: [Key: Value] = [:]
    for rawKey in container.allKeys {
      guard let key = Key(rawValue: rawKey.stringValue) else { throw DecodingError.dataCorruptedError(forKey: rawKey, in: container, debugDescription: "Cannot create \(Value.self) value") }
      let value = try container.decode(Value.self, forKey: rawKey)
      storage[key] = value
    }
    self.wrappedValue = storage
  }

  public func encode(to encoder: Encoder) throws {
    let rawWrappedSequence = wrappedValue.map { ($0.key.rawValue, $0.value) }
    let rawWrappedValue = [String: Value](uniqueKeysWithValues: rawWrappedSequence)
    try rawWrappedValue.encode(to: encoder)
  }

}
