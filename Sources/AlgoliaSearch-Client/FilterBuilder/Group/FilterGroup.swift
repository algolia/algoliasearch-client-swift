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

private class _AnyFilterGroupBase: FilterGroup {
    
    var name: String {
        fatalError("Must override")
    }
    
    var hashValue: Int {
        fatalError("Must override")
    }
    
    init() {
        guard type(of: self) != _AnyFilterGroupBase.self else {
            fatalError("_AnyFilterGroupBase instances can not be created; create a subclass instance instead")
        }
    }
    
    static func == (lhs: _AnyFilterGroupBase, rhs: _AnyFilterGroupBase) -> Bool {
        fatalError("Must override")
    }
    
}

fileprivate final class _AnyFilterGroupBox<Concrete: FilterGroup>: _AnyFilterGroupBase {
    
    fileprivate var concrete: Concrete

    init(_ concrete: Concrete) {
        self.concrete = concrete
    }
    
    override var name: String {
        return concrete.name
    }

    override var hashValue: Int {
        return concrete.hashValue
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
    
    var hashValue: Int {
        return box.hashValue
    }
    
    static func == (lhs: AnyFilterGroup, rhs: AnyFilterGroup) -> Bool {
        return lhs.describingString == rhs.describingString && lhs.name == rhs.name
    }
    
}
