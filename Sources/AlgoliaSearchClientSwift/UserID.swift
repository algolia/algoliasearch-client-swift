//
//  UserID.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct UserID: RawRepresentable {
    
  public let rawValue: String
    
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
}

extension UserID: CustomStringConvertible {
  
  public var description: String {
    return rawValue
  }
  
}

extension UserID: ExpressibleByStringLiteral {
  
  public init(stringLiteral value: String) {
    rawValue = value
  }
  
}
