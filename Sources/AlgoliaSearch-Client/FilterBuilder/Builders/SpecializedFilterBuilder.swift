//
//  SpecializedFilterBuilder.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 26/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// FilterBuilder wrapper accepting filter of a concrete type

public class SpecializedFilterBuilder<T: Filter> {
    
    private let genericFilterBuilder: FilterBuilder
    
    var groups: [AnyFilterGroup: Set<AnyFilter>] {
        return genericFilterBuilder.groups
    }
    
    public init() {
        genericFilterBuilder = FilterBuilder()
    }
    
    public init<T: Filter>(_ filterBuilder: SpecializedFilterBuilder<T>) {
        self.genericFilterBuilder = FilterBuilder(filterBuilder.genericFilterBuilder)
    }
    
    public subscript(group: AndFilterGroup) -> SpecializedAndGroupProxy<T> {
        let genericProxy = genericFilterBuilder[group]
        return SpecializedAndGroupProxy<T>(genericProxy: genericProxy)
    }
    
    public subscript(group: OrFilterGroup<T>) -> OrGroupProxy<T> {
        return OrGroupProxy(filterBuilder: genericFilterBuilder, group: group)
    }
    
    /// A Boolean value indicating whether FilterBuilder contains at least on filter
    public var isEmpty: Bool {
        return genericFilterBuilder.isEmpty
    }
    
    /// Test whether FilterBuilder contains a filter
    /// - parameter filter:
    public func contains(filter: T) -> Bool {
        return genericFilterBuilder.contains(filter)
    }
    
    /// Removes filter from FilterBuilder
    /// - parameter filter: filter to remove
    @discardableResult public func remove(filter: T) -> Bool {
        return genericFilterBuilder.remove(filter)
    }
    
    /// Removes a sequence of filters from FilterBuilder
    /// - parameter filters: sequence of filters to remove
    public func removeAll<S: Sequence>(filters: S) where S.Element == T {
        genericFilterBuilder.removeAll(filters)
    }

    /// Removes all filters with specified attribute in all groups
    /// - parameter attribute: target attribute
    public func removeAll(for attribute: Attribute) {
        genericFilterBuilder.removeAll(for: attribute)
    }
    
    /// Removes all filters in all groups
    public func removeAll() {
        genericFilterBuilder.removeAll()
    }
    
    /// Constructs a string representation of filter
    /// If FilterBuilder is empty returns nil
    /// - parameter ignoringInversion: if set to true, ignores any filter negation
    public func build(ignoringInversion: Bool = false) -> String? {
        return genericFilterBuilder.build(ignoringInversion: ignoringInversion)
    }

}
