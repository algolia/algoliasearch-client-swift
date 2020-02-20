//
//  APIKey.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

public struct APIKey: RawRepresentable {
    
  public let rawValue: String
    
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
}

extension APIKey: CustomStringConvertible {
  
  public var description: String {
    return rawValue
  }
  
}

extension APIKey: ExpressibleByStringLiteral {
  
  public init(stringLiteral value: String) {
    rawValue = value
  }
  
}

