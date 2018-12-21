//
//  FilterBuilderGroupAccessor.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 21/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

extension FilterBuilder {
    
    public subscript(group: AndFilterGroup) -> AndGroupAccessor {
        get {
            return AndGroupAccessor(filterBuilder: self, group: group)
        }
    }
    
    public subscript<T: Filter>(group: OrFilterGroup<T>) -> OrGroupAccessor<T> {
        get {
            return OrGroupAccessor(filterBuilder: self, group: group)
        }
    }
    
}


public struct OrGroupAccessor<T: Filter> {
    
    let filterBuilder: FilterBuilder
    let group: OrFilterGroup<T>

    public func removeAll() {
        filterBuilder.removeAll(in: group)
    }
    
}

public struct AndGroupAccessor {
    
    let filterBuilder: FilterBuilder
    let group: AndFilterGroup
    
    public func removeAll() {
        filterBuilder.removeAll(in: group)
    }
    
}

//public class FilterBuilderGroupAccessor<G: FilterGroup> {
//
//    let filterBuilder: FilterBuilder
//    let group: G
//
//    init(filterBuilder: FilterBuilder, group: AnyGroup) {
//        self.filterBuilder = filterBuilder
//        self.group = group
//    }
//
//    public static func += <T: Filter>(accessor: FilterBuilderGroupAccessor, filter: T) {
//        accessor.filterBuilder.add(filter: filter, in: accessor.group)
//    }
//
//    public static func -= <T: Filter>(accessor: FilterBuilderGroupAccessor, filter: T) {
//        accessor.filterBuilder.remove(filter: filter, in: accessor.group)
//    }
//
//    @discardableResult public static func << <T: Filter>(accessor: FilterBuilderGroupAccessor, filter: T) -> FilterBuilderGroupAccessor {
//        accessor.filterBuilder.add(filter: filter, in: accessor.group)
//        return accessor
//    }
//
//
//
//
//}
//
//extension FilterBuilderGroupAccessor where G == AndFilterGroup {
//
//
//    public func removeAll() {
//        filterBuilder.removeAll(in: group)
//    }
//
//}
//
//extension FilterBuilderGroupAccessor where F: Filter, G == OrFilterGroup<F> {
//
//    public func removeAll() {
//        filterBuilder.removeAll(in: group)
//    }
//
//}
