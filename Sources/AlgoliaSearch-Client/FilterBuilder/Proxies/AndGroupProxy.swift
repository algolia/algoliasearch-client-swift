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
    let group: AnyFilterGroup
    
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
    
    public func add<T: Filter>(_ filter: T) {
        filterBuilder.add(filter, to: group)
    }
    
    public func addAll<T: Filter, S: Sequence>(_ filters: S) where S.Element == T {
        filterBuilder.addAll(filters: filters, to: group)
    }
    
    public func contains<T: Filter>(_ filter: T) -> Bool {
        return filterBuilder.contains(filter: filter, in: group)
    }
    
    public func move<T: Filter>(_ filter: T, to destination: AndFilterGroup) -> Bool {
        return filterBuilder.move(filter: filter, from: group, to: AnyFilterGroup(destination))
    }
    
    public func move<T: Filter>(_ filter: T, to destination: OrFilterGroup<T>) -> Bool {
        return filterBuilder.move(filter: filter, from: group, to: AnyFilterGroup(destination))
    }
    
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        return filterBuilder.replace(attribute, by: replacement, in: group)
    }
    
    public func replace<T: Filter, D: Filter>(_ filter: T, by replacement: D) {
        return filterBuilder.replace(filter: filter, by: replacement, in: group)
    }
    
    public func removeAll(for attribute: Attribute) {
        return filterBuilder.removeAll(for: attribute, from: group)
    }
    
    @discardableResult public func remove<T: Filter>(_ filter: T) -> Bool {
        return filterBuilder.remove(filter, from: group)
    }
    
    @discardableResult public func removeAll<T: Filter, S: Sequence>(_ filters: S) -> Bool where S.Element == T {
        return filterBuilder.removeAll(filters, from: group)
    }
    
    public func removeAll() {
        filterBuilder.removeAll(from: group)
    }

    public func build(ignoringInversion: Bool = false) -> String {
        return filterBuilder.build(group, ignoringInversion: ignoringInversion)
    }

}
