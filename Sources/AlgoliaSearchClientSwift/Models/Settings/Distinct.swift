//
//  Distinct.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

struct Distinct: RawRepresentable, Equatable {
  
  let rawValue: UInt
  
}

extension Distinct: ExpressibleByIntegerLiteral {
  
  init(integerLiteral value: UInt) {
    self.rawValue = value
  }
  
}

extension Distinct: ExpressibleByBooleanLiteral  {
    
  init(booleanLiteral value: Bool) {
    self.rawValue = value ? 1 : 0
  }
  
}

extension Distinct: Codable {
 
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let boolValue = try? container.decode(Bool.self) {
      self.init(booleanLiteral: boolValue)
    } else {
      let intValue = try container.decode(UInt.self)
      self.init(rawValue: intValue)
    }
  }
  
}
