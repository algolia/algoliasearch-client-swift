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
class FilterBuilder {

    var groups: [AnyGroup: Set<AnyFilter>] = [:]

    public func add<T>(filter: T, in group: Group<T>) {
        let anyGroup = AnyGroup(group)

        let groupFilters: Set<AnyFilter>
        if let existingGroupFilters = groups[anyGroup] {
            groupFilters = existingGroupFilters.union([AnyFilter(filter)])
        } else {
            groupFilters = [AnyFilter(filter)]
        }

        groups[anyGroup] = groupFilters
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

    func or<T>(first: T, second: T, others: T...) where T: Filter {

    }

    func useOr() {
        //let filterRange = FilterRange(attribute: Attribute(""), isInverted: true)
        //let filterComp = FilterComparison(attribute: Attribute(""), isInverted: true)

    }
}
