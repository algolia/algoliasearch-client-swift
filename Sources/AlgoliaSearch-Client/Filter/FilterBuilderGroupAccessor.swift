//
//  FilterBuilderGroupAccessor.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 21/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

extension FilterBuilder {
    
    public subscript(group: AndFilterGroup) -> AndGroupProxy {
        get {
            return AndGroupProxy(filterBuilder: self, group: group)
        }
    }
    
    public subscript<T: Filter>(group: OrFilterGroup<T>) -> OrGroupProxy<T> {
        get {
            return OrGroupProxy(filterBuilder: self, group: group)
        }
    }
    
}
