//
//  File.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 07/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// Convenient builder of query filters
/// For better understanding of filters, please read the documentation linked below:
/// [Documentation](https:www.algolia.com/doc/api-reference/api-parameters/filters/)

public class FilterBuilder {
    
    var groups: [AnyFilterGroup: Set<AnyFilter>]

    public init() {
        self.groups = [:]
    }
    
    public init(_ filterBuilder: FilterBuilder) {
        self.groups = filterBuilder.groups
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
    
    func contains<T: Filter>(_ filter: T, in group: AnyFilterGroup) -> Bool {
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
    
    func toggle<T: Filter>(_ filter: T, in group: AnyFilterGroup) {
        if contains(filter, in: group) {
            remove(filter, from: group)
        } else {
            add(filter, to: group)
        }
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

public extension FilterBuilder {
    
    subscript(group: AndFilterGroup) -> AndGroupProxy {
        return AndGroupProxy(filterBuilder: self, group: group)
    }
    
    subscript<T: Filter>(group: OrFilterGroup<T>) -> OrGroupProxy<T> {
        return OrGroupProxy(filterBuilder: self, group: group)
    }
    
    /// A Boolean value indicating whether FilterBuilder contains at least on filter
    public var isEmpty: Bool {
        return groups.isEmpty
    }
    
    /// Tests whether FilterBuilder contains a filter
    /// - parameter filter:
    public func contains<T: Filter>(_ filter: T) -> Bool {
        let anyFilter = AnyFilter(filter)
        return getAllFilters().contains(anyFilter)
    }
    
    /// Replaces all the attribute by a provided one in all filters
    /// - parameter attribute: attribute to replace
    /// - parameter replacement: replacement attribute
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        groups.keys.forEach { group in
            replace(attribute, by: replacement, in: group)
        }
    }
    
    /// Removes filter from source conjunctive group and adds it to destination conjunctive group
    /// - parameter filter: filter to move
    /// - parameter source: source group
    /// - parameter destination: target group
    /// - returns: true if movement succeeded, otherwise returns false
    public func move<T: Filter>(_ filter: T, from source: OrFilterGroup<T>, to destination: AndFilterGroup) -> Bool {
        return move(filter: filter, from: AnyFilterGroup(source), to: AnyFilterGroup(destination))
    }
    
    /// Removes filter from source conjunctive group and adds it to destination disjunctive group
    /// - parameter filter: filter to move
    /// - parameter source: source group
    /// - parameter destination: target group
    /// - returns: true if movement succeeded, otherwise returns false
    public func move<T: Filter>(_ filter: T, from source: AndFilterGroup, to destination: OrFilterGroup<T>) -> Bool {
        return move(filter: filter, from: AnyFilterGroup(source), to: AnyFilterGroup(destination))
    }
    
    /// Removes filter from FilterBuilder
    /// - parameter filter: filter to remove
    @discardableResult public func remove<T: Filter>(_ filter: T) -> Bool {
        return groups.map { remove(filter, from: $0.key) }.reduce(false) { $0 || $1 }
    }
    
    /// Removes a sequence of filters from FilterBuilder
    /// - parameter filters: sequence of filters to remove
    public func removeAll<T: Filter, S: Sequence>(_ filters: S) where S.Element == T {
        let anyFilters = filters.map(AnyFilter.init)
        groups.keys.forEach { group in
            let existingFilters = groups[group] ?? []
            let updatedFilters = existingFilters.subtracting(anyFilters)
            update(updatedFilters, for: group)
        }
    }
    
    /// Removes all filters with specified attribute in all groups
    /// - parameter attribute: target attribute
    public func removeAll(for attribute: Attribute) {
        groups.keys.forEach { group in
            removeAll(for: attribute, from: group)
        }
    }
    
    /// Removes all filters in all groups
    public func removeAll() {
        groups.removeAll()
    }
    
    /// Constructs a string representation of filters
    /// If FilterBuilder is empty returns nil
    /// - parameter ignoringInversion: if set to true, ignores any filter negation
    public func build(ignoringInversion: Bool = false) -> String? {
        guard !isEmpty else { return nil }
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
    
    /// Returns a set of filters of specified type for attribute
    /// - parameter attribute: target attribute
    public func getFilters<T: Filter>(for attribute: Attribute) -> Set<T> {
        let filtersArray: [T] = getAllFilters()
            .filter { $0.attribute == attribute }
            .compactMap { $0.extractAsFilter()  }
        return Set(filtersArray)
    }
    
    /// Returns a set of attributes suitable for disjunctive faceting
    public func getDisjunctiveFacetsAttributes() -> Set<Attribute> {
        let attributes = groups
            .filter { $0.key.isDisjunctive }
            .compactMap { $0.value }
            .flatMap { $0 }
            .map { $0.attribute }
        return Set(attributes)
    }
    
    /// Returns a Boolean value indicating if FilterBuilder contains attributes suitable for disjunctive faceting
    public func isDisjunctiveFacetingAvailable() -> Bool {
        return !getFacetFilters().isEmpty
    }
    
    /// Returns a dictionary of all facet filters with their associated values
    public func getFacetFilters() -> [Attribute: Set<FilterFacet.ValueType>] {
        let facetFilters: [FilterFacet] = groups
            .compactMap { $0.value }
            .flatMap { $0 }
            .compactMap { $0.extractAsFilter() }
        var refinements: [Attribute: Set<FilterFacet.ValueType>] = [:]
        for filter in facetFilters {
            let existingValues = refinements[filter.attribute, default: []]
            let updatedValues = existingValues.union([filter.value])
            refinements[filter.attribute] = updatedValues
        }
        return refinements
    }
    
    /// Returns a raw representaton of all facet filters with their associated values
    public func getRawFacetFilters() -> [String: [String]] {
        var rawRefinments: [String: [String]] = [:]
        getFacetFilters()
            .map { ($0.key.name, $0.value.map { $0.description }) }
            .forEach { attribute, values in
                rawRefinments[attribute] = values
            }
        return rawRefinments
    }
    
}

// MARK: Public methods for conjunctive group

extension FilterBuilder {
    
    /// Adds filter to conjunctive group
    /// - parameter filter: filter to add
    /// - parameter group: target group
    public func add<T: Filter>(_ filter: T, to group: AndFilterGroup) {
        add(filter, to: AnyFilterGroup(group))
    }
    
    /// Adds the filters of a sequence to conjunctive group
    /// - parameter filters: sequence of filters to add
    /// - parameter group: target group
    public func addAll<T: Filter, S: Sequence>(_ filters: S, to group: AndFilterGroup) where S.Element == T {
        addAll(filters: filters, to: AnyFilterGroup(group))
    }
    
    /// Checks whether specified conjunctive group contains a filter
    /// - parameter filter: filter to check
    /// - parameter group: target group
    /// - returns: true if filter is contained by specified group
    public func contains<T: Filter>(_ filter: T, in group: AndFilterGroup) -> Bool {
        return contains(filter, in: AnyFilterGroup(group))
    }
    
    /// Replaces filter in conjunctive group by specified filter replacement
    /// - parameter filter: filter to replace
    /// - parameter replacement: filter replacement
    /// - parameter group: target group
    public func replace<T: Filter, D: Filter>(_ filter: T, by replacement: D, in group: AndFilterGroup) {
        return replace(filter: filter, by: replacement, in: AnyFilterGroup(group))
    }
    
    /// Removes filter from source group and adds it to destination group
    /// - parameter filter: filter to move
    /// - parameter source: source group
    /// - parameter destination: target group
    /// - returns: true if movement succeeded, otherwise returns false
    public func move<T: Filter>(_ filter: T, from source: AndFilterGroup, to destination: AndFilterGroup) -> Bool {
        return move(filter: filter, from: AnyFilterGroup(source), to: AnyFilterGroup(destination))
    }

    /// Removes filter from conjunctive group
    /// - parameter filter: filter to remove
    /// - parameter group: target group
    @discardableResult public func remove<T: Filter>(_ filter: T, from group: AndFilterGroup) -> Bool {
        return remove(filter, from: AnyFilterGroup(group))
    }
    
    /// Removes all filters from conjunctive group
    /// - parameter group: target group
    public func removeAll(from group: AndFilterGroup) {
        removeAll(from: AnyFilterGroup(group))
    }
    
    /// Removes filter from conjunctive group if contained by it, otherwise adds filter to group
    /// - parameter filter: filter to toggle
    /// - parameter group: target group
    public func toggle<T: Filter>(_ filter: T, in group: AndFilterGroup) {
        toggle(filter, in: AnyFilterGroup(group))
    }

}

// MARK: - Public methods for disjunctive group

extension FilterBuilder {
    
    /// Adds filter to disjunctive group
    /// - parameter filter: filter to add
    /// - parameter group: target group
    public func add<T: Filter>(_ filter: T, to group: OrFilterGroup<T>) {
        add(filter, to: AnyFilterGroup(group))
    }
    
    /// Adds the filters of a sequence to disjunctive group
    /// - parameter filters: sequence of filters to add
    /// - parameter group: target group
    public func addAll<T: Filter, S: Sequence>(_ filters: S, to group: OrFilterGroup<T>) where S.Element == T {
        addAll(filters: filters, to: AnyFilterGroup(group))
    }
    
    /// Checks whether specified disjunctive group contains a filter
    /// - parameter filter: filter to check
    /// - parameter group: target group
    /// - returns: true if filter is contained by specified group
    public func contains<T: Filter>(_ filter: T, in group: OrFilterGroup<T>) -> Bool {
        return contains(filter, in: AnyFilterGroup(group))
    }
    
    /// Replaces filter in disjunctive group by specified filter replacement
    /// - parameter filter: filter to replace
    /// - parameter replacement: filter replacement
    /// - parameter group: target group
    public func replace<T: Filter>(_ filter: T, by replacement: T, in group: OrFilterGroup<T>) {
        replace(filter: filter, by: filter, in: AnyFilterGroup(group))
    }
    
    /// Removes filter from source group and adds it to destination group
    /// - parameter filter: filter to move
    /// - parameter source: source group
    /// - parameter destination: target group
    /// - returns: true if movement succeeded, otherwise returns false
    public func move<T: Filter>(_ filter: T, from source: OrFilterGroup<T>, to destination: OrFilterGroup<T>) -> Bool {
        return move(filter: filter, from: AnyFilterGroup(source), to: AnyFilterGroup(destination))
    }
    
    /// Removes filter from disjunctive group
    /// - parameter filter: filter to remove
    /// - parameter group: target group
    @discardableResult public func remove<T: Filter>(_ filter: T, from group: OrFilterGroup<T>) -> Bool {
        return remove(filter, from: AnyFilterGroup(group))
    }
    
    /// Removes all filters from disjunctive group
    /// - parameter group: target group
    public func removeAll<T: Filter>(from group: OrFilterGroup<T>) {
        removeAll(from: AnyFilterGroup(group))
    }
    
    /// Removes filter from disjunctive group if contained by it, otherwise adds filter to group
    /// - parameter filter: filter to toggle
    /// - parameter group: target group
    public func toggle<T: Filter>(_ filter: T, in group: OrFilterGroup<T>) {
        toggle(filter, in: AnyFilterGroup(group))
    }
    
}
