//
//  FilterGroup.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 14/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public protocol FilterGroup: Hashable {
    var name: String { get }
}

public struct OrFilterGroup<F: Filter>: FilterGroup {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public static func or<F: Filter>(_ name: String, ofType: F.Type) -> OrFilterGroup<F> {
        return OrFilterGroup<F>(name: name)
    }
    
}

public struct AndFilterGroup: FilterGroup {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public static func and(_ name: String) -> AndFilterGroup {
        return AndFilterGroup(name: name)
    }
    
}

struct AnyGroup: FilterGroup {

    let hashValue: Int
    let isConjunctive: Bool
    let name: String
    
    init<F: Filter>(_ group: OrFilterGroup<F>) {
        self.hashValue = group.hashValue
        self.isConjunctive = false
        self.name = group.name
    }
    
    init(_ group: AndFilterGroup) {
        self.hashValue = group.hashValue
        self.isConjunctive = true
        self.name = group.name
    }

}
