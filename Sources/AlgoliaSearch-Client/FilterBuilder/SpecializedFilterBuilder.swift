//
//  SpecializedFilterBuilder.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 26/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

// Creates filter builder accepting filters of concrete type

public class SpecializedFilterBuilder<T: Filter> {
    
    private let genericFilterBuilder: FilterBuilder
    
    var groups: [AnyFilterGroup: Set<AnyFilter>] {
        return genericFilterBuilder.groups
    }
    
    public init() {
        genericFilterBuilder = FilterBuilder()
    }
    
    public var isEmpty: Bool {
        return genericFilterBuilder.isEmpty
    }
    
    public func contains(filter: T) -> Bool {
        return genericFilterBuilder.contains(filter)
    }
    
    @discardableResult public func remove(filter: T) -> Bool {
        return genericFilterBuilder.remove(filter)
    }
    
    public func removeAll<S: Sequence>(filters: S) where S.Element == T {
        genericFilterBuilder.removeAll(filters)
    }
    
    public func removeAll(for attribute: Attribute) {
        genericFilterBuilder.removeAll(for: attribute)
    }
    
    public func removeAll() {
        genericFilterBuilder.removeAll()
    }
    
    public func build(ignoringInversion: Bool = false) -> String {
        return genericFilterBuilder.build(ignoringInversion: ignoringInversion)
    }
    
    public subscript(group: AndFilterGroup) -> SpecializedAndGroupProxy<T> {
        let genericProxy = genericFilterBuilder[group]
        return SpecializedAndGroupProxy<T>(genericProxy: genericProxy)
    }
    
    public subscript(group: OrFilterGroup<T>) -> OrGroupProxy<T> {
        return OrGroupProxy(filterBuilder: genericFilterBuilder, group: group)
    }

}
