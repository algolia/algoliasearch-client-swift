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

public typealias FacetTuple = (Attribute, FilterFacet.ValueType)
public typealias ComparisonTuple = (Attribute, NumericOperator, Float)
public typealias RangeTuple = (Attribute, ClosedRange<Float>)

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

// MARK: - Restricted Conjunctive group operators

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

// MARK: - Disjunctive group operators

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
