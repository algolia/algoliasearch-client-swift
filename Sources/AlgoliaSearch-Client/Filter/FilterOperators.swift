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
    higherThan: LogicalConjunctionPrecedence
}

infix operator <<< : FilterGroupPrecedence

@discardableResult public func <<< <T: Filter>(left: OrGroupAccessor<T>, right: T) -> OrGroupAccessor<T> {
    left.filterBuilder.add(filter: right, in: left.group)
    return left
}

@discardableResult public func <<< <T: Filter>(left: AndGroupAccessor, right: T) -> AndGroupAccessor {
    left.filterBuilder.add(filter: right, in: left.group)
    return left
}

@discardableResult public func += <T: Filter>(left: OrGroupAccessor<T>, right: T) -> OrGroupAccessor<T> {
    left.filterBuilder.add(filter: right, in: left.group)
    return left
}

@discardableResult public func += <T: Filter>(left: AndGroupAccessor, right: T) -> AndGroupAccessor {
    left.filterBuilder.add(filter: right, in: left.group)
    return left
}

@discardableResult public func += <T: Filter>(left: OrGroupAccessor<T>, right: [T]) -> OrGroupAccessor<T> {
    left.filterBuilder.addAll(filters: right, in: left.group)
    return left
}

@discardableResult public func += <T: Filter>(left: AndGroupAccessor, right: [T]) -> AndGroupAccessor {
    left.filterBuilder.addAll(filters: right, in: left.group)
    return left
}
