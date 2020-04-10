//
//  FieldWrapper.swift
//  
//
//  Created by Vladislav Fitc on 31/03/2020.
//

import Foundation

struct FieldWrapper<K: Key, Wrapped: Codable>: Codable {
  
  let wrapped: Wrapped
  
  init(_ wrapped: Wrapped) {
    self.wrapped = wrapped
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKey.self)
    self.wrapped = try container.decode(Wrapped.self, forKey: DynamicKey(stringValue: K.value))
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DynamicKey.self)
    try container.encode(wrapped, forKey: DynamicKey(stringValue: K.value))
  }

}
protocol Key {
  static var value: String { get }
}

struct ParamsKey: Key { static let value = "params" }
struct RequestsKey: Key { static let value = "requests" }

typealias ParamsWrapper<Wrapped: Codable> = FieldWrapper<ParamsKey, Wrapped>
typealias RequestsWrapper<Wrapped: Codable> = FieldWrapper<RequestsKey, Wrapped>


