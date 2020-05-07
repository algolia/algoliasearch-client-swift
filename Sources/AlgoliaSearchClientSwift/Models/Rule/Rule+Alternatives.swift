//
//  Rule+Alternatives.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

extension Rule {
  
  public enum Alternatives: RawRepresentable, Codable {
    
    case `true`
    case `false`
    
    public var rawValue: Bool {
      switch self {
      case .true:
        return true
      case .false:
        return false
      }
    }
    
    public init(rawValue: Bool) {
      self = rawValue ? .true : .false
    }
    
  }
  
}
