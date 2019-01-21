//
//  OrGroupOperators.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 21/01/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation

// MARK: Appending

@discardableResult public func +++ <T: Filter>(left: OrGroupProxy<T>, right: T) -> OrGroupProxy<T> {
    left.filterBuilder.add(right, to: left.group)
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == T {
    left.filterBuilder.addAll(filters: right, to: left.group)
    return left
}

@discardableResult public func +++ (left: OrGroupProxy<FilterFacet>, right: FacetTuple) -> OrGroupProxy<FilterFacet> {
    left.filterBuilder.add(FilterFacet(right), to: left.group)
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == FacetTuple {
    left.filterBuilder.addAll(filters: right.map(FilterFacet.init), to: left.group)
    return left
}

@discardableResult public func +++ (left: OrGroupProxy<FilterNumeric>, right: ComparisonTuple) -> OrGroupProxy<FilterNumeric> {
    left.filterBuilder.add(FilterNumeric(right), to: left.group)
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == ComparisonTuple {
    left.filterBuilder.addAll(filters: right.map(FilterNumeric.init), to: left.group)
    return left
}

@discardableResult public func +++ (left: OrGroupProxy<FilterNumeric>, right: RangeTuple) -> OrGroupProxy<FilterNumeric> {
    left.filterBuilder.add(FilterNumeric(right), to: left.group)
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == RangeTuple {
    left.filterBuilder.addAll(filters: right.map(FilterNumeric.init), to: left.group)
    return left
}

@discardableResult public func +++ (left: OrGroupProxy<FilterTag>, right: String) -> OrGroupProxy<FilterTag> {
    left.filterBuilder.add(FilterTag(value: right), to: left.group)
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

@discardableResult public func --- (left: OrGroupProxy<FilterFacet>, right: FacetTuple) -> OrGroupProxy<FilterFacet> {
    left.filterBuilder.remove(FilterFacet(right), from: left.group)
    return left
}

@discardableResult public func --- <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == FacetTuple {
    left.filterBuilder.removeAll(right.map(FilterFacet.init), from: left.group)
    return left
}

@discardableResult public func --- (left: OrGroupProxy<FilterNumeric>, right: ComparisonTuple) -> OrGroupProxy<FilterNumeric> {
    left.filterBuilder.remove(FilterNumeric(right), from: left.group)
    return left
}

@discardableResult public func --- <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == ComparisonTuple {
    left.filterBuilder.removeAll(right.map(FilterNumeric.init), from: left.group)
    return left
}

@discardableResult public func --- (left: OrGroupProxy<FilterNumeric>, right: RangeTuple) -> OrGroupProxy<FilterNumeric> {
    left.filterBuilder.remove(FilterNumeric(right), from: left.group)
    return left
}

@discardableResult public func --- <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == RangeTuple {
    left.filterBuilder.removeAll(right.map(FilterNumeric.init), from: left.group)
    return left
}

@discardableResult public func --- (left: OrGroupProxy<FilterTag>, right: String) -> OrGroupProxy<FilterTag> {
    left.filterBuilder.remove(FilterTag(value: right), from: left.group)
    return left
}

// MARK: - Toggling

@discardableResult public func <> <T: Filter>(left: OrGroupProxy<T>, right: T) -> OrGroupProxy<T> {
    left.toggle(right)
    return left
}

@discardableResult public func <> <T: Filter, S: Sequence>(left: OrGroupProxy<T>, right: S) -> OrGroupProxy<T> where S.Element == T {
    right.forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: OrGroupProxy<FilterFacet>, right: FacetTuple) -> OrGroupProxy<FilterFacet> {
    left.toggle(FilterFacet(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: OrGroupProxy<FilterFacet>, right: S) -> OrGroupProxy<FilterFacet> where S.Element == FacetTuple {
    right.map(FilterFacet.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: OrGroupProxy<FilterNumeric>, right: ComparisonTuple) -> OrGroupProxy<FilterNumeric> {
    left.toggle(FilterNumeric(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: OrGroupProxy<FilterNumeric>, right: S) -> OrGroupProxy<FilterNumeric> where S.Element == ComparisonTuple {
    right.map(FilterNumeric.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: OrGroupProxy<FilterNumeric>, right: RangeTuple) -> OrGroupProxy<FilterNumeric> {
    left.toggle(FilterNumeric(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: OrGroupProxy<FilterNumeric>, right: S) -> OrGroupProxy<FilterNumeric> where S.Element == RangeTuple {
    right.map(FilterNumeric.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: OrGroupProxy<FilterTag>, right: String) -> OrGroupProxy<FilterTag> {
    left.toggle(FilterTag.init(stringLiteral: right))
    return left
}
