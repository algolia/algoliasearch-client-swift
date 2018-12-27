//
//  FilterOperators.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 21/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

precedencegroup FilterGroupPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator +++: FilterGroupPrecedence
infix operator ---: FilterGroupPrecedence

@discardableResult public prefix func ! <T: Filter>(f: T) -> T {
    var mutableFilterCopy = f
    mutableFilterCopy.not(value: !f.isInverted)
    return mutableFilterCopy
}

// MARK: - Conjunctive group operators

// MARK: Appending

@discardableResult public func +++ <T: Filter>(left: AndGroupProxy, right: T) -> AndGroupProxy {
    left.filterBuilder.add(right, to: left.group)
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == T {
    left.filterBuilder.addAll(filters: right, to: left.group)
    return left
}

@discardableResult public func +++ (left: AndGroupProxy, right: (Attribute, NumericOperator, Float)) -> AndGroupProxy {
    let numericFilter = FilterNumeric(attribute: right.0, operator: right.1, value: right.2)
    left.filterBuilder.add(numericFilter, to: left.group)
    return left
}

@discardableResult public func +++ (left: AndGroupProxy, right: (Attribute, ClosedRange<Float>)) -> AndGroupProxy {
    let numericFilter = FilterNumeric(attribute: right.0, range: right.1)
    left.filterBuilder.add(numericFilter, to: left.group)
    return left
}

@discardableResult public func +++ (left: AndGroupProxy, right: String) -> AndGroupProxy {
    left.filterBuilder.add(FilterTag(value: right), to: left.group)
    return left
}

@discardableResult public func +++ (left: AndGroupProxy, right: (Attribute, FilterFacet.ValueType)) -> AndGroupProxy {
    let filterFacet = FilterFacet(attribute: right.0, value: right.1)
    left.filterBuilder.add(filterFacet, to: left.group)
    return left
}

// MARK: Removal

@discardableResult public func --- <T: Filter>(left: AndGroupProxy, right: T) -> AndGroupProxy {
    left.filterBuilder.remove(right, from: left.group)
    return left
}

@discardableResult public func --- <T: Filter, S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == T {
    left.filterBuilder.removeAll(right, from: left.group)
    return left
}

@discardableResult public func --- (left: AndGroupProxy, right: (Attribute, NumericOperator, Float)) -> AndGroupProxy {
    let numericFilter = FilterNumeric(attribute: right.0, operator: right.1, value: right.2)
    left.filterBuilder.remove(numericFilter, from: left.group)
    return left
}

@discardableResult public func --- (left: AndGroupProxy, right: (Attribute, ClosedRange<Float>)) -> AndGroupProxy {
    let numericFilter = FilterNumeric(attribute: right.0, range: right.1)
    left.filterBuilder.remove(numericFilter, from: left.group)
    return left
}

@discardableResult public func --- (left: AndGroupProxy, right: String) -> AndGroupProxy {
    left.filterBuilder.remove(FilterTag(value: right), from: left.group)
    return left
}

@discardableResult public func --- (left: AndGroupProxy, right: (Attribute, FilterFacet.ValueType)) -> AndGroupProxy {
    let filterFacet = FilterFacet(attribute: right.0, value: right.1)
    left.filterBuilder.remove(filterFacet, from: left.group)
    return left
}

// MARK: - Disjunctive group operators

// MARK: Appending

@discardableResult public func +++ <T: Filter>(left: OrGroupProxy<T>, right: T) -> OrGroupProxy<T> {
    left.filterBuilder.add(right, to: left.group)
    return left
}

@discardableResult public func +++ <T: Filter>(left: OrGroupProxy<T>, right: [T]) -> OrGroupProxy<T> {
    left.filterBuilder.addAll(filters: right, to: left.group)
    return left
}

@discardableResult public func +++ (left: OrGroupProxy<FilterNumeric>, right: (Attribute, NumericOperator, Float)) -> OrGroupProxy<FilterNumeric> {
    let numericFilter = FilterNumeric(attribute: right.0, operator: right.1, value: right.2)
    left.filterBuilder.add(numericFilter, to: left.group)
    return left
}

@discardableResult public func +++ (left: OrGroupProxy<FilterNumeric>, right: (Attribute, ClosedRange<Float>)) -> OrGroupProxy<FilterNumeric> {
    let numericFilter = FilterNumeric(attribute: right.0, range: right.1)
    left.filterBuilder.add(numericFilter, to: left.group)
    return left
}

@discardableResult public func +++ (left: OrGroupProxy<FilterTag>, right: String) -> OrGroupProxy<FilterTag> {
    left.filterBuilder.add(FilterTag(value: right), to: left.group)
    return left
}

@discardableResult public func +++ (left: OrGroupProxy<FilterFacet>, right: (Attribute, FilterFacet.ValueType)) -> OrGroupProxy<FilterFacet> {
    let filterFacet = FilterFacet(attribute: right.0, value: right.1)
    left.filterBuilder.add(filterFacet, to: left.group)
    return left
}

// MARK: Removal

@discardableResult public func --- <T: Filter>(left: OrGroupProxy<T>, right: T) -> OrGroupProxy<T> {
    left.filterBuilder.remove(right, from: left.group)
    return left
}

@discardableResult public func --- <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == T {
    left.filterBuilder.removeAll(right, from: left.group)
    return left
}

@discardableResult public func --- (left: OrGroupProxy<FilterNumeric>, right: (Attribute, NumericOperator, Float)) -> OrGroupProxy<FilterNumeric> {
    let numericFilter = FilterNumeric(attribute: right.0, operator: right.1, value: right.2)
    left.filterBuilder.remove(numericFilter, from: left.group)
    return left
}

@discardableResult public func --- (left: OrGroupProxy<FilterNumeric>, right: (Attribute, ClosedRange<Float>)) -> OrGroupProxy<FilterNumeric> {
    let numericFilter = FilterNumeric(attribute: right.0, range: right.1)
    left.filterBuilder.remove(numericFilter, from: left.group)
    return left
}

@discardableResult public func --- (left: OrGroupProxy<FilterTag>, right: String) -> OrGroupProxy<FilterTag> {
    left.filterBuilder.remove(FilterTag(value: right), from: left.group)
    return left
}

@discardableResult public func --- (left: OrGroupProxy<FilterFacet>, right: (Attribute, FilterFacet.ValueType)) -> OrGroupProxy<FilterFacet> {
    let filterFacet = FilterFacet(attribute: right.0, value: right.1)
    left.filterBuilder.remove(filterFacet, from: left.group)
    return left
}
