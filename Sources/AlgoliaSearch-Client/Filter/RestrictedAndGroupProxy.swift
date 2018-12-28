//
//  RestrictedAndGroupProxy.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 26/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

// AND group proxy accepting filter of a concrete type

public struct RestrictedAndGroupProxy<T: Filter> {
    
    private let genericProxy: AndGroupProxy
    
    var group: AnyGroup {
        return genericProxy.group
    }
    
    public var isEmpty: Bool {
        return genericProxy.isEmpty
    }
    
    init(genericProxy: AndGroupProxy) {
        self.genericProxy = genericProxy
    }
    
    public func add(_ filter: T) {
        genericProxy.add(filter)
    }
    
    public func addAll<T: Filter, S: Sequence>(_ filters: S) where S.Element == T {
        genericProxy.addAll(filters)
    }
    
    public func contains(_ filter: T) -> Bool {
        return genericProxy.contains(filter)
    }
    
    public func move(_ filter: T, to destination: AndFilterGroup) -> Bool {
        return genericProxy.move(filter, to: destination)
    }
    
    public func move(_ filter: T, to destination: OrFilterGroup<T>) -> Bool {
        return genericProxy.move(filter, to: destination)
    }
    
    public func replace(_ attribute: Attribute, by replacement: Attribute) {
        return genericProxy.replace(attribute, by: replacement)
    }
    
    public func replace<T: Filter, D: Filter>(_ filter: T, by replacement: D) {
        return genericProxy.replace(filter, by: replacement)
    }
    
    public func removeAll(for attribute: Attribute) {
        return genericProxy.removeAll(for: attribute)
    }
    
    @discardableResult public func remove(_ filter: T) -> Bool {
        return genericProxy.remove(filter)
    }
    
    @discardableResult public func removeAll<S: Sequence>(_ filters: S) -> Bool where S.Element == T {
        return genericProxy.removeAll(filters)
    }
    
    public func removeAll() {
        genericProxy.removeAll()
    }
    
    public func build() -> String {
        return genericProxy.build()
    }
    
}
