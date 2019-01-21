//
//  AndGroupOperators.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 21/01/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation

// MARK: Appending

@discardableResult public func +++ <T: Filter>(left: AndGroupProxy, right: T) -> AndGroupProxy {
    left.filterBuilder.add(right, to: left.group)
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == T {
    left.filterBuilder.addAll(filters: right, to: left.group)
    return left
}

@discardableResult public func +++ (left: AndGroupProxy, right: FacetTuple) -> AndGroupProxy {
    left.filterBuilder.add(FilterFacet(right), to: left.group)
    return left
}

@discardableResult public func +++ <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == FacetTuple {
    left.filterBuilder.addAll(filters: right.map(FilterFacet.init), to: left.group)
    return left
}

@discardableResult public func +++ (left: AndGroupProxy, right: ComparisonTuple) -> AndGroupProxy {
    left.filterBuilder.add(FilterNumeric(right), to: left.group)
    return left
}

@discardableResult public func +++ <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == ComparisonTuple {
    left.filterBuilder.addAll(filters: right.map(FilterNumeric.init), to: left.group)
    return left
}

@discardableResult public func +++ (left: AndGroupProxy, right: RangeTuple) -> AndGroupProxy {
    left.filterBuilder.add(FilterNumeric(right), to: left.group)
    return left
}

@discardableResult public func +++ <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == RangeTuple {
    left.filterBuilder.addAll(filters: right.map(FilterNumeric.init), to: left.group)
    return left
}

@discardableResult public func +++ (left: AndGroupProxy, right: String) -> AndGroupProxy {
    left.filterBuilder.add(FilterTag(value: right), to: left.group)
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

@discardableResult public func --- (left: AndGroupProxy, right: FacetTuple) -> AndGroupProxy {
    left.filterBuilder.remove(FilterFacet(right), from: left.group)
    return left
}

@discardableResult public func --- <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == FacetTuple {
    left.filterBuilder.removeAll(right.map(FilterFacet.init), from: left.group)
    return left
}

@discardableResult public func --- (left: AndGroupProxy, right: ComparisonTuple) -> AndGroupProxy {
    left.filterBuilder.remove(FilterNumeric(right), from: left.group)
    return left
}

@discardableResult public func --- <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == ComparisonTuple {
    left.filterBuilder.removeAll(right.map(FilterNumeric.init), from: left.group)
    return left
}

@discardableResult public func --- (left: AndGroupProxy, right: RangeTuple) -> AndGroupProxy {
    left.filterBuilder.remove(FilterNumeric(right), from: left.group)
    return left
}

@discardableResult public func --- <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == RangeTuple {
    left.filterBuilder.removeAll(right.map(FilterNumeric.init), from: left.group)
    return left
}

@discardableResult public func --- (left: AndGroupProxy, right: String) -> AndGroupProxy {
    left.filterBuilder.remove(FilterTag(value: right), from: left.group)
    return left
}

// MARK: - Toggling

@discardableResult public func <> <T: Filter>(left: AndGroupProxy, right: T) -> AndGroupProxy {
    left.toggle(right)
    return left
}

@discardableResult public func <> <T: Filter, S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == T {
    right.forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: AndGroupProxy, right: FacetTuple) -> AndGroupProxy {
    left.toggle(FilterFacet(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == FacetTuple {
    right.map(FilterFacet.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: AndGroupProxy, right: ComparisonTuple) -> AndGroupProxy {
    left.toggle(FilterNumeric(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == ComparisonTuple {
    right.map(FilterNumeric.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: AndGroupProxy, right: RangeTuple) -> AndGroupProxy {
    left.toggle(FilterNumeric(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: AndGroupProxy, right: S) -> AndGroupProxy where S.Element == RangeTuple {
    right.map(FilterNumeric.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: AndGroupProxy, right: String) -> AndGroupProxy {
    left.toggle(FilterTag.init(stringLiteral: right))
    return left
}
