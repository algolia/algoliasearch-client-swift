//
//  AndGroupProxy.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 24/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// Provides a specific type-safe interface for FilterBuilder specialized for a conjunctive group

public struct AndGroupProxy: GroupProxy {
    
    let filterBuilder: FilterBuilder
    let group: AnyFilterGroup
    
    /// A Boolean value indicating whether group contains at least on filter
    public var isEmpty: Bool {
        if let filtersForGroup = filterBuilder.groups[group] {
            return filtersForGroup.isEmpty
        } else {
            return true
        }
    }
    
    init(filterBuilder: FilterBuilder, group: AndFilterGroup) {
        self.filterBuilder = filterBuilder
        self.group = AnyFilterGroup(group)
    }
    
    /// Adds filter to group
    /// - parameter filter: filter to add
    public func add<T: Filter>(_ filter: T) {
        filterBuilder.add(filter, to: group)
    }
    
    /// Adds the filters of a sequence to group
    /// - parameter filters: sequence of filters to add
    public func addAll<T: Filter, S: Sequence>(_ filters: S) where S.Element == T {
        filterBuilder.addAll(filters: filters, to: group)
    }
    
    /// Tests whether group contains a filter
    /// - parameter filter: sought filter
    public func contains<T: Filter>(_ filter: T) -> Bool {
        return filterBuilder.contains(filter, in: group)
    }
    
    /// Removes filter from current group and adds it to destination conjunctive group
    /// - parameter filter: filter to move
    /// - parameter destination: target group
    /// - returns: true if movement succeeded, otherwise returns false
    public func move<T: Filter>(_ filter: T, to destination: AndFilterGroup) -> Bool {
        return filterBuilder.move(filter: filter, from: group, to: AnyFilterGroup(destination))
    }
    
    /// Removes filter from current group and adds it to destination disjunctive group
    /// - parameter filter: filter to move
    /// - parameter destination: target group
    /// - returns: true if movement succeeded, otherwise returns false
    public func move<T: Filter>(_ filter: T, to destination: OrFilterGroup<T>) -> Bool {
        return filterBuilder.move(filter: filter, from: group, to: AnyFilterGroup(destination))
    }
    
    /// Replaces all the attribute by a provided one in group
    /// - parameter attribute: attribute to replace
    /// - parameter replacement: replacement attribute
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        return filterBuilder.replace(attribute, by: replacement, in: group)
    }
    
    /// Replaces filter in group by specified filter replacement
    /// - parameter filter: filter to replace
    /// - parameter replacement: filter replacement
    public func replace<T: Filter, D: Filter>(_ filter: T, by replacement: D) {
        return filterBuilder.replace(filter: filter, by: replacement, in: group)
    }
    
    /// Removes all filters with specified attribute from group
    /// - parameter attribute: specified attribute
    public func removeAll(for attribute: Attribute) {
        return filterBuilder.removeAll(for: attribute, from: group)
    }
    
    /// Removes filter from group
    /// - parameter filter: filter to remove
    @discardableResult public func remove<T: Filter>(_ filter: T) -> Bool {
        return filterBuilder.remove(filter, from: group)
    }
    
    /// Removes a sequence of filters from group
    /// - parameter filters: sequence of filters to remove
    @discardableResult public func removeAll<T: Filter, S: Sequence>(_ filters: S) -> Bool where S.Element == T {
        return filterBuilder.removeAll(filters, from: group)
    }
    
    /// Removes all filters in group
    public func removeAll() {
        filterBuilder.removeAll(from: group)
    }
    
    /// Removes filter from group if contained by it, otherwise adds filter to group
    /// - parameter filter: filter to toggle
    public func toggle<T: Filter>(_ filter: T) {
        filterBuilder.toggle(filter, in: group)
    }

    /// Constructs a string representation of filters in group
    /// If group is empty returns nil
    /// - parameter ignoringInversion: if set to true, ignores any filter negation
    public func build(ignoringInversion: Bool = false) -> String {
        return filterBuilder.build(group, ignoringInversion: ignoringInversion)
    }

}
