//
//  File.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 07/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// For better understanding of Filters, please read the documentation linked below:
/// [Documentation](https:www.algolia.com/doc/api-reference/api-parameters/filters/)
public class FilterBuilder {

    public init() {}
    
    var groups: [AnyGroup: Set<AnyFilter>] = [:]
    
    private func update(_ filters: Set<AnyFilter>, for group: AnyGroup) {
        groups[group] = filters.isEmpty ? nil : filters
    }
    
    func add<T: Filter>(filter: T, in group: AnyGroup) {
        addAll(filters: [filter], in: group)
    }
    
    func addAll<T: Filter>(filters: [T], in group: AnyGroup) {
        let existingFilters = groups[group] ?? []
        let updatedFilters = existingFilters.union(filters.map(AnyFilter.init))
        update(updatedFilters, for: group)
    }
    
    @discardableResult func remove<T: Filter>(filter: T, in anyGroup: AnyGroup) -> Bool {
        return removeAll(filters: [filter], in: anyGroup)
    }
    
    @discardableResult func removeAll<T: Filter>(filters: [T], in anyGroup: AnyGroup) -> Bool {
        let filtersToRemove = filters.map(AnyFilter.init)
        guard let existingFilters = groups[anyGroup], !existingFilters.isDisjoint(with: filtersToRemove) else {
            return false
        }
        let updatedFilters = existingFilters.subtracting(filtersToRemove)
        update(updatedFilters, for: anyGroup)
        return true
    }
    
    func removeAll(in group: AnyGroup) {
        groups.removeValue(forKey: group)
    }
    
    func contains<T: Filter>(filter: T, in group: AnyGroup) -> Bool {
        let anyFilter = AnyFilter(filter)
        guard let filtersForGroup = groups[group] else {
            return false
        }
        return filtersForGroup.contains(anyFilter)
    }
    
    func replace(_ attribute: Attribute, by replacement: Attribute, in group: AnyGroup) {
        guard let filtersForGroup = groups[group] else { return }
        let filtersToReplace = filtersForGroup.filter { $0.attribute == attribute }
        let filtersReplacements = filtersToReplace.map { $0.with(replacement) }
        let updatedFilters = filtersForGroup.subtracting(filtersToReplace).union(filtersReplacements)
        update(updatedFilters, for: group)
    }
    
    func replace<T: Filter, D: Filter>(filter: T, by replacement: D, in group: AnyGroup) {
        guard let filtersForGroup = groups[group] else { return }
        let filtersToReplace = filtersForGroup.filter { AnyFilter(filter) == $0 }
        let filtersReplacement = [AnyFilter(replacement)]
        let updatedFilters = filtersForGroup.subtracting(filtersToReplace).union(filtersReplacement)
        update(updatedFilters, for: group)
    }
    
    func replace<T: Filter>(_ filter: T, by replacement: T) {
        groups.keys.forEach { group in
            replace(filter: filter, by: replacement, in: group)
        }
    }
    
    func removeAll(for attribute: Attribute, in group: AnyGroup) {
        guard let filtersForGroup = groups[group] else { return }
        let updatedFilters = filtersForGroup.filter { $0.attribute != attribute }
        update(updatedFilters, for: group)
    }

    func build(_ group: AnyGroup) -> String {
        
        let filters = groups[group] ?? []
        
        let sortedFiltersExpressions = filters
            .sorted { $0.expression < $1.expression }
            .map { $0.expression }
        
        if group.isConjunctive {
            return sortedFiltersExpressions.joined(separator: " AND ")
        } else {
            let subfilter = sortedFiltersExpressions.joined(separator: " OR ")
            return filters.count > 1 ? "( \(subfilter) )" : subfilter
        }
        
    }

}

// MARK: - Public interface

extension FilterBuilder {
    
    public var isEmpty: Bool {
        return groups.isEmpty
    }
    
    public func contains<T: Filter>(filter: T) -> Bool {
        let anyFilter = AnyFilter(filter)
        return groups.values.reduce(Set<AnyFilter>(), { $0.union($1) }).contains(anyFilter)
    }
    
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        groups.keys.forEach { group in
            replace(attribute, by: replacement, in: group)
        }
    }
    
    @discardableResult public func remove<T: Filter>(filter: T) -> Bool {
        return groups.map { remove(filter: filter, in: $0.key) }.reduce(false) { $0 || $1 }
    }
    
    public func removeAll<T: Filter>(filters: [T]) {
        let anyFilters = filters.map(AnyFilter.init)
        groups.keys.forEach { group in
            let existingFilters = groups[group] ?? []
            let updatedFilters = existingFilters.subtracting(anyFilters)
            update(updatedFilters, for: group)
        }
    }
    
    public func removeAll(for attribute: Attribute) {
        groups.keys.forEach { group in
            removeAll(for: attribute, in: group)
        }
    }
    
    public func removeAll() {
        groups.removeAll()
    }
    
    public func build() -> String {
        return groups
            .keys
            .sorted {
                $0.name != $1.name
                ? $0.name < $1.name
                : $0.isConjunctive
            }
            .map(build)
            .joined(separator: " AND ")
    }
    
}

// MARK: Public group type-specific interface

extension FilterBuilder {
    
    public func add<T: Filter>(filter: T, in group: AndFilterGroup) {
        AndGroupProxy(filterBuilder: self, group: group).add(filter: filter)
    }
    
    public func add<T: Filter>(filter: T, in group: OrFilterGroup<T>) {
        OrGroupProxy(filterBuilder: self, group: group).add(filter: filter)
    }
    
    public func addAll<T: Filter>(filters: [T], in group: OrFilterGroup<T>) {
        OrGroupProxy(filterBuilder: self, group: group).addAll(filters: filters)
    }
    
    public func addAll<T: Filter>(filters: [T], in group: AndFilterGroup) {
        AndGroupProxy(filterBuilder: self, group: group).addAll(filters: filters)
    }
    
    public func contains<T: Filter>(_ filter: T, in group: OrFilterGroup<T>) -> Bool {
        return OrGroupProxy(filterBuilder: self, group: group).contains(filter)
    }
    
    func replace<T: Filter>(filter: T, by replacement: T, in group: OrFilterGroup<T>) {
        OrGroupProxy(filterBuilder: self, group: group).replace(filter, by: replacement)
    }

    func replace<T: Filter, D: Filter>(filter: T, by replacement: D, in group: AndFilterGroup) {
        AndGroupProxy(filterBuilder: self, group: group).replace(filter, by: replacement)
    }

    public func contains<T: Filter>(_ filter: T, in group: AndFilterGroup) -> Bool {
        return AndGroupProxy(filterBuilder: self, group: group).contains(filter)
    }

    @discardableResult public func remove<T: Filter>(filter: T, in group: AndFilterGroup) -> Bool {
        return AndGroupProxy(filterBuilder: self, group: group).remove(filter: filter)
    }
    
    @discardableResult public func remove<T: Filter>(filter: T, in group: OrFilterGroup<T>) -> Bool {
        return OrGroupProxy(filterBuilder: self, group: group).remove(filter: filter)
    }
    
    public func removeAll(in group: AndFilterGroup) {
        AndGroupProxy(filterBuilder: self, group: group).removeAll()
    }
    
    public func removeAll<T: Filter>(in group: OrFilterGroup<T>) {
        OrGroupProxy(filterBuilder: self, group: group).removeAll()
    }
    
}
