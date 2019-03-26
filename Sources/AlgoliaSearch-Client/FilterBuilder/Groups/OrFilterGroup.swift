//
//  OrFilterGroup.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 14/01/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation

/// Representation of disjunctive group of filters

public struct OrFilterGroup<T: Filter>: FilterGroup {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public static func or<T: Filter>(_ name: String) -> OrFilterGroup<T> {
        return OrFilterGroup<T>(name: name)
    }
    
    public static func or<T: Filter>(_ name: String, ofType: T.Type) -> OrFilterGroup<T> {
        return OrFilterGroup<T>(name: name)
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
    }
    
}
