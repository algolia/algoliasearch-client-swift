//
//  Builder.swift
//
//
//  Created by Vladislav Fitc on 31/03/2020.
//

import Foundation

public protocol Builder {}

extension Builder {
  public func set<T>(_ keyPath: WritableKeyPath<Self, T>, to newValue: T) -> Self {
    var copy = self
    copy[keyPath: keyPath] = newValue
    return copy
  }

  public func setIfNotNil<T>(_ keyPath: WritableKeyPath<Self, T>, to newValue: T?) -> Self {
    guard let value = newValue else { return self }
    var copy = self
    copy[keyPath: keyPath] = value
    return copy
  }
}
