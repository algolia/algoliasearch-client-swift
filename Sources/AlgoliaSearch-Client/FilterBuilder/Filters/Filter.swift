//
//  Filter.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 07/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// Abstract filter protocol
public protocol Filter: Hashable {

    /// Identifier of field affected by filter
    var attribute: Attribute { get }
    
    /// A Boolean value indicating whether filter is inverted
    var isNegated: Bool { get set }

    /// String representation of filter excluding negation
    var expression: String { get }
    
    /// Replaces isNegated property by a new value
    /// parameter value: new value of isNegated
    mutating func not(value: Bool)
    
    /// Returns string representation of filter
    /// - parameter ignoringInversion: if set to true, ignores filter negation
    func build(ignoringInversion: Bool) -> String
    
    /// Returns the same filter with attribute replaced by a provided one
    /// - parameter attribute: attribute replacement
    func replacingAttribute(by attribute: Attribute) -> Self
}

/**
 As Filter protocol inherits Hashable protocol, it cannot be used as a type, but only as a type constraint.
 For the purpose of workaround it, a type-erased wrapper AnyFilter is introduced.
 You can find more information about type erasure here:
 https://www.bignerdranch.com/blog/breaking-down-type-erasures-in-swift/
 */

private class _AnyFilterBase: AbstractClass, Filter {
    
    var attribute: Attribute {
        callMustOverrideError()
    }
    
    var isNegated: Bool {
        get { callMustOverrideError() }
        set { callMustOverrideError() }
    }
    
    var expression: String {
        callMustOverrideError()
    }

    func hash(into hasher: inout Hasher) {
        callMustOverrideError()
    }
    
    init() {
        guard type(of: self) != _AnyFilterBase.self else {
            impossibleInitError()
        }
    }
    
    func replacingAttribute(by attribute: Attribute) -> Self {
        callMustOverrideError()
    }
    
    static func == (lhs: _AnyFilterBase, rhs: _AnyFilterBase) -> Bool {
        callMustOverrideError()
    }
    
}

private final class _AnyFilterBox<Concrete: Filter>: _AnyFilterBase {

    var concrete: Concrete
    
    init(_ concrete: Concrete) {
        self.concrete = concrete
    }
    
    override var attribute: Attribute {
        return concrete.attribute
    }
    
    override var isNegated: Bool {
        get { return concrete.isNegated }
        set { concrete.isNegated = newValue }
    }
    
    override var expression: String {
        return concrete.expression
    }

    override func hash(into hasher: inout Hasher) {
      hasher.combine(concrete)
    }
    
    override func replacingAttribute(by attribute: Attribute) -> _AnyFilterBox {
        return _AnyFilterBox(concrete.replacingAttribute(by: attribute))
    }
    
    static func == (lhs: _AnyFilterBox, rhs: _AnyFilterBox) -> Bool {
        return lhs.concrete == rhs.concrete
    }
    
}

final class AnyFilter: Filter {
    
    private let box: _AnyFilterBase
    
    init<Concrete: Filter>(_ concrete: Concrete) {
        box = _AnyFilterBox(concrete)
    }
    
    var attribute: Attribute {
        return box.attribute
    }
    
    var isNegated: Bool {
        get { return box.isNegated }
        set { box.isNegated = newValue }
    }
    
    var expression: String {
        return box.expression
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(box)
    }
    
    func replacingAttribute(by attribute: Attribute) -> AnyFilter {
        return AnyFilter(box.replacingAttribute(by: attribute))
    }
    
    static func == (lhs: AnyFilter, rhs: AnyFilter) -> Bool {
        return lhs.box.expression == rhs.box.expression
    }
    
    func extractAsFilter<T: Filter>() -> T? {
        return (box as? _AnyFilterBox<T>)?.concrete
    }
    
}

extension Filter {
    public func build(ignoringInversion: Bool = false) -> String {
        if !isNegated || ignoringInversion {
            return expression
        } else {
            return "NOT \(expression)"
        }
    }

    public mutating func not(value: Bool = true) {
        isNegated = value
    }
}
