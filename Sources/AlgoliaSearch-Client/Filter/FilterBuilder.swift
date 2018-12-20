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

    public func add<T: Filter>(filter: T, in group: Group<T>) {
        let anyGroup = AnyGroup(group)

        let groupFilters: Set<AnyFilter>
        if let existingGroupFilters = groups[anyGroup] {
            groupFilters = existingGroupFilters.union([AnyFilter(filter)])
        } else {
            groupFilters = [AnyFilter(filter)]
        }

        groups[anyGroup] = groupFilters
    }

    public func addAll<T: Filter>(filters: [T], in group: Group<T>) {
        filters.forEach { add(filter: $0, in: group) }
    }

    public func remove<T: Filter>(filter: T, in group: Group<T>) {
        let anyGroup = AnyGroup(group)
        remove(filter: filter, in: anyGroup)
    }

    func remove<T: Filter>(filter: T, in anyGroup: AnyGroup) {
        if var filters = groups[anyGroup] {
            filters.remove(AnyFilter(filter))
            groups[anyGroup] = filters.isEmpty ? nil : filters
        }
    }

    public func remove<T: Filter>(filter: T) {
        groups.forEach { remove(filter: filter, in: $0.key) }
    }

    public func removeAll<T: Filter>(filters: [T]) {
        filters.forEach { remove(filter: $0) }
    }
    
    public func contains<T: Filter>(filter: T) -> Bool {
        let anyFilter = AnyFilter(filter)
        return groups.values.reduce(Set<AnyFilter>(), { $0.union($1) }).contains(anyFilter)
    }
    
    public func clear(_ attribute: Attribute) {
        groups.forEach { group in
            let updatedFilters = group.value.filter { $0.attribute != attribute }
            groups[group.key] = updatedFilters.isEmpty ? nil : updatedFilters
        }
    }
    
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        groups.forEach { group in
            let filtersToReplace = group.value.filter { $0.attribute == attribute }
            let filtersReplacements = filtersToReplace.map { $0.with(replacement) }
            let updatedFilters = group.value.subtracting(filtersToReplace).union(filtersReplacements)
            groups[group.key] = updatedFilters.isEmpty ? nil : updatedFilters

        }
    }
    
    public func replace<T: Filter>(_ filter: T, by replacement: T) {
        groups.forEach { group in
            let filtersToReplace = group.value.filter { AnyFilter(filter) == $0 }
            let filtersReplacement = [AnyFilter(replacement)]
            let updatedFilters = group.value.subtracting(filtersToReplace).union(filtersReplacement)
            groups[group.key] = updatedFilters
        }
    }
    
    public func clear() {
        groups.removeAll()
    }

    func build(_ group: AnyGroup, with filters: Set<AnyFilter>) -> String {

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

    public func build() -> String {
        return groups
            .sorted {
                $0.key.name != $1.key.name
                ? $0.key.name < $1.key.name
                : $0.key.isConjunctive
            }
            .map { build($0.key, with: $0.value) }
            .joined(separator: " AND ")
    }

    /*
     * To represent our SQL-like syntax of filters, we use a nested array of [Filter].
     * Each nested MutableList<Filter> represents a group. If this group contains two or more elements,
     * it will be considered  as a disjunctive group (Operator OR).
     * The operator AND will be used between each nested group.
     *
     * Example:
     *
     * ((FilterA), (FilterB), (FilterC, FilterD), (FilterE, FilterF))
     *
     * will give us the following SQL-like expression:
     *
     * FilterA AND FilterB AND (FilterC OR FilterD) AND (FilterE OR FilterF)
     */
    //private var filters = mutableListOf<MutableList<Filter>>()

    func useOr() {
        //let filterRange = FilterRange(attribute: Attribute(""), isInverted: true)
        //let filterComp = FilterComparison(attribute: Attribute(""), isInverted: true)

    }
}
