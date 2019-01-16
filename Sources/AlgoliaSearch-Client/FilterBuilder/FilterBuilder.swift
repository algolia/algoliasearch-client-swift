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
    
    var groups: [AnyFilterGroup: Set<AnyFilter>] = [:]
    
    public subscript(group: AndFilterGroup) -> AndGroupProxy {
        return AndGroupProxy(filterBuilder: self, group: group)
    }
    
    public subscript<T: Filter>(group: OrFilterGroup<T>) -> OrGroupProxy<T> {
        return OrGroupProxy(filterBuilder: self, group: group)
    }
    
    private func update(_ filters: Set<AnyFilter>, for group: AnyFilterGroup) {
        groups[group] = filters.isEmpty ? nil : filters
    }
    
    func add<T: Filter>(_ filter: T, to group: AnyFilterGroup) {
        addAll(filters: [filter], to: group)
    }
    
    func addAll<T: Filter, S: Sequence>(filters: S, to group: AnyFilterGroup) where S.Element == T {
        let existingFilters = groups[group] ?? []
        let updatedFilters = existingFilters.union(filters.map(AnyFilter.init))
        update(updatedFilters, for: group)
    }
    
    func contains<T: Filter>(filter: T, in group: AnyFilterGroup) -> Bool {
        let anyFilter = AnyFilter(filter)
        guard let filtersForGroup = groups[group] else {
            return false
        }
        return filtersForGroup.contains(anyFilter)
    }
    
    func replace(_ attribute: Attribute, by replacement: Attribute, in group: AnyFilterGroup) {
        guard let filtersForGroup = groups[group] else { return }
        let filtersToReplace = filtersForGroup.filter { $0.attribute == attribute }
        let filtersReplacements = filtersToReplace.map { $0.replacingAttribute(by: replacement) }
        let updatedFilters = filtersForGroup.subtracting(filtersToReplace).union(filtersReplacements)
        update(updatedFilters, for: group)
    }
    
    func replace<T: Filter, D: Filter>(filter: T, by replacement: D, in group: AnyFilterGroup) {
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
    
    func move<T: Filter>(filter: T, from origin: AnyFilterGroup, to destination: AnyFilterGroup) -> Bool {
        if remove(filter, from: origin) {
            add(filter, to: destination)
            return true
        }
        return false
    }
    
    @discardableResult func remove<T: Filter>(_ filter: T, from anyGroup: AnyFilterGroup) -> Bool {
        return removeAll([filter], from: anyGroup)
    }
    
    @discardableResult func removeAll<T: Filter, S: Sequence>(_ filters: S, from anyGroup: AnyFilterGroup) -> Bool where S.Element == T {
        let filtersToRemove = filters.map(AnyFilter.init)
        guard let existingFilters = groups[anyGroup], !existingFilters.isDisjoint(with: filtersToRemove) else {
            return false
        }
        let updatedFilters = existingFilters.subtracting(filtersToRemove)
        update(updatedFilters, for: anyGroup)
        return true
    }
    
    func removeAll(from group: AnyFilterGroup) {
        groups.removeValue(forKey: group)
    }
    
    func removeAll(for attribute: Attribute, from group: AnyFilterGroup) {
        guard let filtersForGroup = groups[group] else { return }
        let updatedFilters = filtersForGroup.filter { $0.attribute != attribute }
        update(updatedFilters, for: group)
    }

    func build(_ group: AnyFilterGroup, ignoringInversion: Bool) -> String {
        
        let filters = groups[group] ?? []
        
        let sortedFiltersExpressions = filters
            .sorted { $0.expression < $1.expression }
            .map { $0.build(ignoringInversion: ignoringInversion) }
        
        if group.isConjunctive {
            return sortedFiltersExpressions.joined(separator: " AND ")
        } else {
            let subfilter = sortedFiltersExpressions.joined(separator: " OR ")
            return filters.count > 1 ? "( \(subfilter) )" : subfilter
        }
        
    }
    
    func getAllFilters() -> Set<AnyFilter> {
        return groups.values.reduce(Set<AnyFilter>(), { $0.union($1) })
    }

}

// MARK: - Public interface

extension FilterBuilder {
    
    public var isEmpty: Bool {
        return groups.isEmpty
    }
    
    public func contains<T: Filter>(_ filter: T) -> Bool {
        let anyFilter = AnyFilter(filter)
        return getAllFilters().contains(anyFilter)
    }
    
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        groups.keys.forEach { group in
            replace(attribute, by: replacement, in: group)
        }
    }
    
    @discardableResult public func remove<T: Filter>(_ filter: T) -> Bool {
        return groups.map { remove(filter, from: $0.key) }.reduce(false) { $0 || $1 }
    }
    
    public func removeAll<T: Filter, S: Sequence>(_ filters: S) where S.Element == T {
        let anyFilters = filters.map(AnyFilter.init)
        groups.keys.forEach { group in
            let existingFilters = groups[group] ?? []
            let updatedFilters = existingFilters.subtracting(anyFilters)
            update(updatedFilters, for: group)
        }
    }
    
    public func removeAll(for attribute: Attribute) {
        groups.keys.forEach { group in
            removeAll(for: attribute, from: group)
        }
    }
    
    public func removeAll() {
        groups.removeAll()
    }
    
    public func build(ignoringInversion: Bool = false) -> String {
        return groups
            .keys
            .sorted {
                $0.name != $1.name
                ? $0.name < $1.name
                : $0.isConjunctive
            }
            .map { build($0, ignoringInversion: ignoringInversion) }
            .joined(separator: " AND ")
    }
    
    public func getFilters<T: Filter>(for attribute: Attribute) -> Set<T> {
        let filtersArray: [T] = getAllFilters()
            .filter { $0.attribute == attribute }
            .compactMap { $0.extractAs()  }
        return Set(filtersArray)
    }
    
    public func disjunctiveFacetsAttributes() -> Set<Attribute> {
        let attributes = groups
            .filter { $0.key.isDisjunctive }
            .compactMap { $0.value }
            .flatMap { $0 }
            .map { $0.attribute }
        return Set(attributes)
    }
    
    public func isDisjunctiveFacetingRequired() -> Bool {
        return !refinements().isEmpty
    }
    
    public func refinements() -> [Attribute: Set<FilterFacet.ValueType>] {
        let facetFilters: [FilterFacet] = groups
            .filter { $0.key.isDisjunctive }
            .compactMap { $0.value }
            .flatMap { $0 }
            .compactMap { $0.extractAs() }
        var refinements: [Attribute: Set<FilterFacet.ValueType>] = [:]
        for filter in facetFilters {
            refinements[filter.attribute] = refinements[filter.attribute, default: []].union([filter.value])
        }
        return refinements
    }
    
    public func rawRefinements() -> [String: [String]] {
        var rawRefinments: [String: [String]] = [:]
        refinements().map({ ($0.key.name, $0.value.map { $0.description }) }).forEach { attribute, values in
            rawRefinments[attribute] = values
        }
        return rawRefinments
    }
    
}

extension Sequence where Element: Equatable {
    
    func containsDuplicates(of element: Element) -> Bool {
        var foundOnce = false
        for el in self where el == element {
            if foundOnce {
                return true
            } else {
                foundOnce = true
            }
        }
        return false
    }
    
}

// MARK: AndFilterGroup methods

extension FilterBuilder {
    
    public func add<T: Filter>(_ filter: T, to group: AndFilterGroup) {
        add(filter, to: AnyFilterGroup(group))
    }
    
    public func addAll<T: Filter, S: Sequence>(_ filters: S, to group: AndFilterGroup) where S.Element == T {
        addAll(filters: filters, to: AnyFilterGroup(group))
    }
    
    public func contains<T: Filter>(_ filter: T, in group: AndFilterGroup) -> Bool {
        return contains(filter: filter, in: AnyFilterGroup(group))
    }
    
    public func replace<T: Filter, D: Filter>(_ filter: T, by replacement: D, in group: AndFilterGroup) {
        return replace(filter: filter, by: replacement, in: AnyFilterGroup(group))
    }
    
    public func move<T: Filter>(_ filter: T, from source: AndFilterGroup, to destination: AndFilterGroup) -> Bool {
        return move(filter: filter, from: AnyFilterGroup(source), to: AnyFilterGroup(destination))
    }

    @discardableResult public func remove<T: Filter>(_ filter: T, from group: AndFilterGroup) -> Bool {
        return remove(filter, from: AnyFilterGroup(group))
    }
    
    public func removeAll(from group: AndFilterGroup) {
        removeAll(from: AnyFilterGroup(group))
    }

}

// MARK: - OrFilterGroup methods

extension FilterBuilder {
    
    public func add<T: Filter>(_ filter: T, to group: OrFilterGroup<T>) {
        add(filter, to: AnyFilterGroup(group))
    }
    
    public func addAll<T: Filter, S: Sequence>(_ filters: S, to group: OrFilterGroup<T>) where S.Element == T {
        addAll(filters: filters, to: AnyFilterGroup(group))
    }
    
    public func contains<T: Filter>(_ filter: T, in group: OrFilterGroup<T>) -> Bool {
        return contains(filter: filter, in: AnyFilterGroup(group))
    }
    
    public func replace<T: Filter>(_ filter: T, by replacement: T, in group: OrFilterGroup<T>) {
        replace(filter: filter, by: filter, in: AnyFilterGroup(group))
    }
    
    public func move<T: Filter>(_ filter: T, from source: OrFilterGroup<T>, to destination: OrFilterGroup<T>) -> Bool {
        return move(filter: filter, from: AnyFilterGroup(source), to: AnyFilterGroup(destination))
    }
    
    public func move<T: Filter>(_ filter: T, from source: OrFilterGroup<T>, to destination: AndFilterGroup) -> Bool {
        return move(filter: filter, from: AnyFilterGroup(source), to: AnyFilterGroup(destination))
    }
    
    public func move<T: Filter>(_ filter: T, from source: AndFilterGroup, to destination: OrFilterGroup<T>) -> Bool {
        return move(filter: filter, from: AnyFilterGroup(source), to: AnyFilterGroup(destination))
    }
    
    @discardableResult public func remove<T: Filter>(_ filter: T, from group: OrFilterGroup<T>) -> Bool {
        return remove(filter, from: AnyFilterGroup(group))
    }
    
    public func removeAll<T: Filter>(from group: OrFilterGroup<T>) {
        removeAll(from: AnyFilterGroup(group))
    }
    
}
