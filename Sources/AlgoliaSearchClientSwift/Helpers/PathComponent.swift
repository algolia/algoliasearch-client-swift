//
//  PathComponent.swift
//  
//
//  Created by Vladislav Fitc on 05/04/2020.
//

import Foundation

protocol PathComponent {

  associatedtype Parent: PathComponent

  var rawValue: String { get }

  var parent: Parent? { get set }

}

protocol RootPath: PathComponent where Parent == Never {

}

extension RootPath {

  var parent: Parent? {
    get {
      return nil
    }

    set { }
  }

}

extension Never: PathComponent {

  var rawValue: String {
    return ""
  }

  var parent: Never? {
    get {
      return nil
    }
    set {
    }
  }

}

extension PathComponent {

  static func >>> (lhs: Self.Parent, rhs: Self) -> Self {
    var copy = rhs
    copy.parent = lhs
    return copy
  }

  var fullPath: String {
    return [parent?.fullPath, rawValue].compactMap { $0 }.joined(separator: "/")
  }

}

precedencegroup PathPrecedence {
  lowerThan: DefaultPrecedence
  associativity: left
}

infix operator >>>: PathPrecedence
