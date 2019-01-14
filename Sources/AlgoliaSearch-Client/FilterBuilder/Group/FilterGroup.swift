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


public func ==<T: Filter>(lhs: OrFilterGroup<T>, rhs: OrFilterGroup<T>) -> Bool {
    return lhs.name == rhs.name && String(describing: lhs) == String(describing: rhs)
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
