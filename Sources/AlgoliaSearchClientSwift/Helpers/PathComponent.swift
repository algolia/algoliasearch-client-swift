//
//  PathComponent.swift
//  
//
//  Created by Vladislav Fitc on 05/04/2020.
//

import Foundation

protocol PathComponent {
  
  associatedtype Ascendant: PathComponent
  
  var rawValue: String { get }
  
  var asc: Ascendant? { get set }
  
}

extension Never: PathComponent {
  
  var rawValue: String {
    return ""
  }
    
  var asc: Never? {
    get {
      return nil
    }
    set {
    }
  }
  
}

extension PathComponent {
  
  static func >>>(lhs: Self.Ascendant, rhs: Self) -> Self {
    var copy = rhs
    copy.asc = lhs
    return copy
  }
  
  var fullPath: String {
    return [asc?.fullPath, rawValue].compactMap { $0 }.joined(separator: "/")
  }
  
}


precedencegroup PathPrecedence {
  lowerThan: DefaultPrecedence
  associativity: left
}

infix operator >>>: PathPrecedence
