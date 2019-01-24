//
//  SpecializedAndGroupProxy.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 26/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// Provides a specific type-safe interface for FilterBuilder specialized for a conjunctive group specialized for filters of concrete type

public struct SpecializedAndGroupProxy<T: Filter> {
    
    private let genericProxy: AndGroupProxy
    
    var group: AnyFilterGroup {
        return genericProxy.group
    }
    
    /// A Boolean value indicating whether group contains at least on filter
    public var isEmpty: Bool {
        return genericProxy.isEmpty
    }
    
    init(genericProxy: AndGroupProxy) {
        self.genericProxy = genericProxy
    }
    
    /// Adds filter to group
    /// - parameter filter: filter to add
    public func add(_ filter: T) {
        genericProxy.add(filter)
    }
    
    /// Adds the filters of a sequence to group
    /// - parameter filters: sequence of filters to add
    public func addAll<T: Filter, S: Sequence>(_ filters: S) where S.Element == T {
        genericProxy.addAll(filters)
    }
    
    /// Tests whether group contains a filter
    /// - parameter filter: sought filter
    public func contains(_ filter: T) -> Bool {
        return genericProxy.contains(filter)
    }
    
    /// Removes filter from current group and adds it to destination conjunctive group
    /// - parameter filter: filter to move
    /// - parameter destination: target group
    /// - returns: true if movement succeeded, otherwise returns false
    public func move(_ filter: T, to destination: AndFilterGroup) -> Bool {
        return genericProxy.move(filter, to: destination)
    }
    
    /// Removes filter from current group and adds it to destination disjunctive group
    /// - parameter filter: filter to move
    /// - parameter destination: target group
    /// - returns: true if movement succeeded, otherwise returns false
    public func move(_ filter: T, to destination: OrFilterGroup<T>) -> Bool {
        return genericProxy.move(filter, to: destination)
    }
    
    /// Replaces all the attribute by a provided one in group
    /// - parameter attribute: attribute to replace
    /// - parameter replacement: replacement attribute
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        return genericProxy.replace(attribute, by: replacement)
    }
    
    /// Replaces filter in group by specified filter replacement
    /// - parameter filter: filter to replace
    /// - parameter replacement: filter replacement
    public func replace<T: Filter, D: Filter>(_ filter: T, by replacement: D) {
        return genericProxy.replace(filter, by: replacement)
    }
    
    /// Removes all filters with specified attribute from group
    /// - parameter attribute: specified attribute
    public func removeAll(for attribute: Attribute) {
        return genericProxy.removeAll(for: attribute)
    }
    
    /// Removes filter from group
    /// - parameter filter: filter to remove
    @discardableResult public func remove(_ filter: T) -> Bool {
        return genericProxy.remove(filter)
    }
    
    /// Removes a sequence of filters from group
    /// - parameter filters: sequence of filters to remove
    @discardableResult public func removeAll<S: Sequence>(_ filters: S) -> Bool where S.Element == T {
        return genericProxy.removeAll(filters)
    }
    
    /// Removes all filters in group
    public func removeAll() {
        genericProxy.removeAll()
    }
    
    /// Removes filter from group if contained by it, otherwise adds filter to group
    /// - parameter filter: filter to toggle
    public func toggle(_ filter: T) {
        genericProxy.toggle(filter)
    }
    
    /// Constructs a string representation of filters in group
    /// If FilterBuilder is empty returns nil
    /// - parameter ignoringInversion: if set to true, ignores any filter negation
    public func build() -> String {
        return genericProxy.build()
    }
    
}
