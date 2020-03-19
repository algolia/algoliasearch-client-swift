//
//  Facet.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation

/// A value of a given facet, together with its number of occurrences.
/// This struct is mainly useful when an ordered list of facet values has to be presented to the user.
///
public struct Facet: Codable, Equatable, Hashable {
    public let value: String
    public let count: Int
    public let highlighted: String?

  public init(value: String, count: Int, highlighted: String? = nil) {
    self.value = value
    self.count = count
    self.highlighted = highlighted
  }
}

public extension Facet {
  
  var isEmpty: Bool {
    return count < 1
  }
  
}

extension Facet: CustomStringConvertible {
  
  public var description: String {
    return "\(value) (\(count))"
  }
  
}

extension Dictionary where Key == String, Value == [String: Int] {
  
  init(_ facetsForAttribute: [Attribute: [Facet]]) {
    self = [:]
    for facetForAttribute in facetsForAttribute {
      let rawAttribute = facetForAttribute.key.description
      self[rawAttribute] = [String: Int](facetForAttribute.value)
    }
  }
  
}

extension Dictionary where Key == String, Value == Int {
  
  init(_ facets: [Facet]) {
    self = [:]
    for facet in facets {
      self[facet.value] = facet.count
    }
  }
  
}
