//
//  FilterGroup.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 14/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public protocol FilterGroup: Hashable {
    var name: String { get }
}

public func ==<T: Filter>(lhs: OrFilterGroup<T>, rhs: OrFilterGroup<T>) -> Bool {
    return lhs.name == rhs.name && String(describing: lhs) == String(describing: rhs)
}

/**
 As FilterGroup protocol inherits Hashable protocol, it cannot be used as a type, but only as a type constraint.
 For the purpose of workaround it, a type-erased wrapper AnyFilterGroup is introduced.
 You can find more information about type erasure here:
 https://www.bignerdranch.com/blog/breaking-down-type-erasures-in-swift/
 */

private class _AnyFilterGroupBase: AbstractClass, FilterGroup {
    
    var name: String {
        callMustOverrideError()
    }

    func hash(into hasher: inout Hasher) {
        callMustOverrideError()
    }
    
    init() {
        guard type(of: self) != _AnyFilterGroupBase.self else {
            impossibleInitError()
        }
    }
    
    static func == (lhs: _AnyFilterGroupBase, rhs: _AnyFilterGroupBase) -> Bool {
        callMustOverrideError()
    }
    
}

private final class _AnyFilterGroupBox<Concrete: FilterGroup>: _AnyFilterGroupBase {
    
    var concrete: Concrete

    init(_ concrete: Concrete) {
        self.concrete = concrete
    }
    
    override var name: String {
        return concrete.name
    }

    override func hash(into hasher: inout Hasher) {
      hasher.combine(concrete)
    }

    static func == (lhs: _AnyFilterGroupBox, rhs: _AnyFilterGroupBox) -> Bool {
        return lhs.concrete == rhs.concrete
    }
    
}

final class AnyFilterGroup: FilterGroup {
    
    private let box: _AnyFilterGroupBase
    private let describingString: String
    
    var isConjunctive: Bool {
        return (extractAs() as AndFilterGroup?) != nil
    }
    
    var isDisjunctive: Bool {
        return !isConjunctive
    }
    
    init<Concrete: FilterGroup>(_ concrete: Concrete) {
        box = _AnyFilterGroupBox(concrete)
        describingString = String(describing: concrete)
    }
    
    var name: String {
        return box.name
    }
    
    func extractAs<T: FilterGroup>() -> T? {
        return (box as? _AnyFilterGroupBox<T>)?.concrete
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(box)
    }
    
    static func == (lhs: AnyFilterGroup, rhs: AnyFilterGroup) -> Bool {
        return lhs.describingString == rhs.describingString && lhs.name == rhs.name
    }
    
}
