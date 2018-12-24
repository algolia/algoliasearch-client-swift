//
//  OrGroupProxy.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 24/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public struct OrGroupProxy<T: Filter>: GroupProxy {
    
    let filterBuilder: FilterBuilder
    let group: AnyGroup
    
    public var isEmpty: Bool {
        if let filtersForGroup = filterBuilder.groups[group] {
            return filtersForGroup.isEmpty
        } else {
            return true
        }
    }
    
    init(filterBuilder: FilterBuilder, group: OrFilterGroup<T>) {
        self.filterBuilder = filterBuilder
        self.group = AnyGroup(group)
    }
    
    public func add(filter: T) {
        filterBuilder.add(filter: filter, in: group)
    }
    
    public func addAll(filters: [T]) {
        filterBuilder.addAll(filters: filters, in: group)
    }
    
    public func contains(_ filter: T) -> Bool {
        return filterBuilder.contains(filter: filter, in: group)
    }
    
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        return filterBuilder.replace(attribute, by: replacement, in: group)
    }
    
    public func replace(_ filter: T, by replacement: T) {
        return filterBuilder.replace(filter: filter, by: replacement, in: group)
    }
    
    @discardableResult public func remove(filter: T) -> Bool {
        return filterBuilder.remove(filter: filter, in: group)
    }
    
    @discardableResult public func removeAll(filters: [T]) -> Bool {
        return filterBuilder.removeAll(filters: filters, in: group)
    }
    
    public func removeAll(for attribute: Attribute) {
        return filterBuilder.removeAll(for: attribute, in: group)
    }

    public func removeAll() {
        filterBuilder.removeAll(in: group)
    }
    
    public func build() -> String {
        return filterBuilder.build(group)
    }
    
}
