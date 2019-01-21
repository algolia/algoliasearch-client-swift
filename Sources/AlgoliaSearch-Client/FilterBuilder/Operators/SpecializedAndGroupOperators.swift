//
//  SpecializedAndGroupOperators.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 21/01/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation

// MARK: Appending

@discardableResult public func +++ <T: Filter>(left: SpecializedAndGroupProxy<T>, right: T) -> SpecializedAndGroupProxy<T> {
    left.add(right)
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: SpecializedAndGroupProxy<T>, right: S) -> SpecializedAndGroupProxy<T> where S.Element == T {
    left.addAll(right)
    return left
}

@discardableResult public func +++ (left: SpecializedAndGroupProxy<FilterFacet>, right: FacetTuple) -> SpecializedAndGroupProxy<FilterFacet> {
    left.add(FilterFacet(right))
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: SpecializedAndGroupProxy<T>, right: S) -> SpecializedAndGroupProxy<T> where S.Element == FacetTuple {
    left.addAll(right.map(FilterFacet.init))
    return left
}

@discardableResult public func +++ (left: SpecializedAndGroupProxy<FilterNumeric>, right: ComparisonTuple) -> SpecializedAndGroupProxy<FilterNumeric> {
    left.add(FilterNumeric(right))
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: SpecializedAndGroupProxy<T>, right: S) -> SpecializedAndGroupProxy<T> where S.Element == ComparisonTuple {
    left.addAll(right.map(FilterNumeric.init))
    return left
}

@discardableResult public func +++ (left: SpecializedAndGroupProxy<FilterNumeric>, right: RangeTuple) -> SpecializedAndGroupProxy<FilterNumeric> {
    left.add(FilterNumeric(right))
    return left
}

@discardableResult public func +++ <T: Filter, S: Sequence>(left: SpecializedAndGroupProxy<T>, right: S) -> SpecializedAndGroupProxy<T> where S.Element == RangeTuple {
    left.addAll(right.map(FilterNumeric.init))
    return left
}

@discardableResult public func +++ (left: SpecializedAndGroupProxy<FilterTag>, right: String) -> SpecializedAndGroupProxy<FilterTag> {
    left.add(FilterTag(value: right))
    return left
}

// MARK: Removal

@discardableResult public func --- <T: Filter>(left: SpecializedAndGroupProxy<T>, right: T) -> SpecializedAndGroupProxy<T> {
    left.remove(right)
    return left
}

@discardableResult public func --- <T: Filter, S: Sequence>(left: SpecializedAndGroupProxy<T>, right: S) -> SpecializedAndGroupProxy<T> where S.Element == T {
    left.removeAll(right)
    return left
}

@discardableResult public func --- (left: SpecializedAndGroupProxy<FilterFacet>, right: FacetTuple) -> SpecializedAndGroupProxy<FilterFacet> {
    left.remove(FilterFacet(right))
    return left
}

@discardableResult public func --- <S: Sequence>(left: SpecializedAndGroupProxy<FilterFacet>, right: S) -> SpecializedAndGroupProxy<FilterFacet> where S.Element == FacetTuple {
    left.removeAll(right.map(FilterFacet.init))
    return left
}

@discardableResult public func --- (left: SpecializedAndGroupProxy<FilterNumeric>, right: ComparisonTuple) -> SpecializedAndGroupProxy<FilterNumeric> {
    left.remove(FilterNumeric(right))
    return left
}

@discardableResult public func --- <S: Sequence>(left: SpecializedAndGroupProxy<FilterNumeric>, right: S) -> SpecializedAndGroupProxy<FilterNumeric> where S.Element == ComparisonTuple {
    left.removeAll(right.map(FilterNumeric.init))
    return left
}

@discardableResult public func --- (left: SpecializedAndGroupProxy<FilterNumeric>, right: RangeTuple) -> SpecializedAndGroupProxy<FilterNumeric> {
    left.remove(FilterNumeric(right))
    return left
}

@discardableResult public func --- <S: Sequence>(left: SpecializedAndGroupProxy<FilterNumeric>, right: S) -> SpecializedAndGroupProxy<FilterNumeric> where S.Element == RangeTuple {
    left.removeAll(right.map(FilterNumeric.init))
    return left
}

@discardableResult public func --- (left: SpecializedAndGroupProxy<FilterTag>, right: String) -> SpecializedAndGroupProxy<FilterTag> {
    left.remove(FilterTag(value: right))
    return left
}

// MARK: - Toggling

@discardableResult public func <> <T: Filter>(left: SpecializedAndGroupProxy<T>, right: T) -> SpecializedAndGroupProxy<T> {
    left.toggle(right)
    return left
}

@discardableResult public func <> <T: Filter, S: Sequence>(left: SpecializedAndGroupProxy<T>, right: S) -> SpecializedAndGroupProxy<T> where S.Element == T {
    right.forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: SpecializedAndGroupProxy<FilterFacet>, right: FacetTuple) -> SpecializedAndGroupProxy<FilterFacet> {
    left.toggle(FilterFacet(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: SpecializedAndGroupProxy<FilterFacet>, right: S) -> SpecializedAndGroupProxy<FilterFacet> where S.Element == FacetTuple {
    right.map(FilterFacet.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: SpecializedAndGroupProxy<FilterNumeric>, right: ComparisonTuple) -> SpecializedAndGroupProxy<FilterNumeric> {
    left.toggle(FilterNumeric(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: SpecializedAndGroupProxy<FilterNumeric>, right: S) -> SpecializedAndGroupProxy<FilterNumeric> where S.Element == ComparisonTuple {
    right.map(FilterNumeric.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: SpecializedAndGroupProxy<FilterNumeric>, right: RangeTuple) -> SpecializedAndGroupProxy<FilterNumeric> {
    left.toggle(FilterNumeric(right))
    return left
}

@discardableResult public func <> <S: Sequence>(left: SpecializedAndGroupProxy<FilterNumeric>, right: S) -> SpecializedAndGroupProxy<FilterNumeric> where S.Element == RangeTuple {
    right.map(FilterNumeric.init).forEach(left.toggle)
    return left
}

@discardableResult public func <> (left: SpecializedAndGroupProxy<FilterTag>, right: String) -> SpecializedAndGroupProxy<FilterTag> {
    left.toggle(FilterTag.init(stringLiteral: right))
    return left
}
