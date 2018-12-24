//
//  AndGroupProxy.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 24/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public struct AndGroupProxy: GroupProxy {
    
    let filterBuilder: FilterBuilder
    let group: AnyGroup
    
    public var isEmpty: Bool {
        if let filtersForGroup = filterBuilder.groups[group] {
            return filtersForGroup.isEmpty
        } else {
            return true
        }
    }
    
    init(filterBuilder: FilterBuilder, group: AndFilterGroup) {
        self.filterBuilder = filterBuilder
        self.group = AnyGroup(group)
    }
    
    public func add<T: Filter>(filter: T) {
        filterBuilder.add(filter: filter, in: group)
    }
    
    public func addAll<T: Filter>(filters: [T]) {
        filterBuilder.addAll(filters: filters, in: group)
    }
    
    public func contains<T: Filter>(_ filter: T) -> Bool {
        return filterBuilder.contains(filter: filter, in: group)
    }
    
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        return filterBuilder.replace(attribute, by: replacement, in: group)
    }
    
    public func replace<T: Filter, D: Filter>(_ filter: T, by replacement: D) {
        return filterBuilder.replace(filter: filter, by: replacement, in: group)
    }
    
    public func removeAll(for attribute: Attribute) {
        return filterBuilder.removeAll(for: attribute, in: group)
    }
    
    @discardableResult public func remove<T: Filter>(filter: T) -> Bool {
        return filterBuilder.remove(filter: filter, in: group)
    }
    
    @discardableResult public func removeAll<T: Filter>(filters: [T]) -> Bool {
        return filterBuilder.removeAll(filters: filters, in: group)
    }
    
    public func removeAll() {
        filterBuilder.removeAll(in: group)
    }

    public func build() -> String {
        return filterBuilder.build(group)
    }

}
