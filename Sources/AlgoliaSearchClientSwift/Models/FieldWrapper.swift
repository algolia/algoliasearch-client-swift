//
//  FieldWrapper.swift
//  
//
//  Created by Vladislav Fitc on 31/03/2020.
//

import Foundation

struct FieldWrapper<Wrapped: Codable> {
  
  let fieldname: String
  let wrapped: Wrapped
  
}

extension FieldWrapper {
  
  init(requests: Wrapped) {
    self.fieldname = "requests"
    self.wrapped = requests
  }
  
  init(params: Wrapped) {
    self.fieldname = "params"
    self.wrapped = params
  }
  
}

extension FieldWrapper: Codable {
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKey.self)
    self.fieldname = container.allKeys.first!.stringValue
    self.wrapped = try container.decode(Wrapped.self, forKey: DynamicKey(stringValue: fieldname))
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DynamicKey.self)
    try container.encode(wrapped, forKey: DynamicKey(stringValue: fieldname))
  }
  
}
