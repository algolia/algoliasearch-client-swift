//
//  ApplicationID.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct ApplicationID: RawRepresentable {
    
  public let rawValue: String
    
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
}

extension ApplicationID: CustomStringConvertible {
  
  public var description: String {
    return rawValue
  }
  
}

extension ApplicationID: ExpressibleByStringLiteral {
  
  public init(stringLiteral value: String) {
    rawValue = value
  }
  
}
