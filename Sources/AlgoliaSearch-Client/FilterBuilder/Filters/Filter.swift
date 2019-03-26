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
    var isInverted: Bool { get set }

    /// String representation of filter excluding negation
    var expression: String { get }
    
    /// Replaces isInverted property by a new value
    /// parameter value: new value of isInverted
    mutating func not(value: Bool)
    
    /// Returns string representation of filter
    /// - parameter ignoringInversion: if set to true, ignores filter negation
    func build(ignoringInversion: Bool) -> String
    
    /// Returns the same filter with attribute replaced by a provided one
    /// - parameter attribute: attribute replacement
    func replacingAttribute(by attribute: Attribute) -> Self
}

private class _AnyFilterBase: Filter {
    
    var attribute: Attribute {
        fatalError("Must override")
    }
    
    var isInverted: Bool {
        get { fatalError("Must override") }
        
        set { fatalError("Must override") }
    }
    
    var expression: String {
        fatalError("Must override")
    }

    func hash(into hasher: inout Hasher) {
      fatalError("Must override")
    }
    
    init() {
        guard type(of: self) != _AnyFilterBase.self else {
            fatalError("_AnyFilterBase instances can not be created; create a subclass instance instead")
        }
    }
    
    func replacingAttribute(by attribute: Attribute) -> Self {
        fatalError("Must override")
    }
    
    static func == (lhs: _AnyFilterBase, rhs: _AnyFilterBase) -> Bool {
        fatalError("Must override")
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
    
    override var isInverted: Bool {
        get { return concrete.isInverted }
        set { concrete.isInverted = newValue }
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
    
    var isInverted: Bool {
        get { return box.isInverted }
        set { box.isInverted = newValue }
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
        if !isInverted || ignoringInversion {
            return expression
        } else {
            return "NOT \(expression)"
        }
    }

    public mutating func not(value: Bool = true) {
        isInverted = value
    }
}
