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
    
    public func add(_ filter: T) {
        filterBuilder.add(filter, to: group)
    }
    
    public func addAll<S: Sequence>(_ filters: S) where S.Element == T {
        filterBuilder.addAll(filters: filters, to: group)
    }
    
    public func contains(_ filter: T) -> Bool {
        return filterBuilder.contains(filter: filter, in: group)
    }
    
    public func move(_ filter: T, to destination: AndFilterGroup) -> Bool {
        return filterBuilder.move(filter: filter, from: group, to: AnyGroup(destination))
    }
    
    public func move(_ filter: T, to destination: OrFilterGroup<T>) -> Bool {
        return filterBuilder.move(filter: filter, from: group, to: AnyGroup(destination))
    }
    
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        return filterBuilder.replace(attribute, by: replacement, in: group)
    }
    
    public func replace(_ filter: T, by replacement: T) {
        return filterBuilder.replace(filter: filter, by: replacement, in: group)
    }
    
    @discardableResult public func remove(_ filter: T) -> Bool {
        return filterBuilder.remove(filter, from: group)
    }
    
    @discardableResult public func removeAll<S: Sequence>(_ filters: S) -> Bool where S.Element == T {
        return filterBuilder.removeAll(filters, from: group)
    }
    
    public func removeAll(for attribute: Attribute) {
        return filterBuilder.removeAll(for: attribute, from: group)
    }

    public func removeAll() {
        filterBuilder.removeAll(from: group)
    }
    
    public func build(ignoringInversion: Bool = false) -> String {
        return filterBuilder.build(group, ignoringInversion: ignoringInversion)
    }
    
}
