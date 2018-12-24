//
//  FilterOperators.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 21/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

precedencegroup FilterBuilderPrecedence {
    associativity: left
    higherThan: FilterGroupPrecedence
}

precedencegroup FilterGroupPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator +++: FilterGroupPrecedence
infix operator ---: FilterGroupPrecedence
infix operator <<< : FilterGroupPrecedence

@discardableResult public func +++ <T: Filter>(left: OrGroupProxy<T>, right: T) -> OrGroupProxy<T> {
    left.filterBuilder.add(filter: right, in: left.group)
    return left
}

@discardableResult public func +++ <T: Filter>(left: AndGroupProxy, right: T) -> AndGroupProxy {
    left.filterBuilder.add(filter: right, in: left.group)
    return left
}

@discardableResult public func --- <T: Filter>(left: OrGroupProxy<T>, right: T) -> OrGroupProxy<T> {
    left.filterBuilder.remove(filter: right, in: left.group)
    return left
}

@discardableResult public func --- <T: Filter>(left: AndGroupProxy, right: T) -> AndGroupProxy {
    left.filterBuilder.remove(filter: right, in: left.group)
    return left
}

@discardableResult public func +++ <T: Filter>(left: OrGroupProxy<T>, right: [T]) -> OrGroupProxy<T> {
    left.filterBuilder.addAll(filters: right, in: left.group)
    return left
}

@discardableResult public func +++ <T: Filter>(left: AndGroupProxy, right: [T]) -> AndGroupProxy {
    left.filterBuilder.addAll(filters: right, in: left.group)
    return left
}

@discardableResult public func --- <T: Filter>(left: OrGroupProxy<T>, right: [T]) -> OrGroupProxy<T> {
    left.filterBuilder.removeAll(filters: right, in: left.group)
    return left
}

@discardableResult public func --- <T: Filter>(left: AndGroupProxy, right: [T]) -> AndGroupProxy {
    left.filterBuilder.removeAll(filters: right, in: left.group)
    return left
}
