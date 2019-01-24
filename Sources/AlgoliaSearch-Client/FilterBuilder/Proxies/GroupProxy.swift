//
//  GroupProxy.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 24/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// Group proxy provides a specific type-safe interface for FilterBuilder specialized for a concrete group
internal protocol GroupProxy {
    var filterBuilder: FilterBuilder { get }
    var group: AnyFilterGroup { get }
}
