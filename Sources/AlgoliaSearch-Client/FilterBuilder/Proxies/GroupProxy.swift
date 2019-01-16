//
//  GroupProxy.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 24/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

internal protocol GroupProxy {
    var filterBuilder: FilterBuilder { get }
    var group: AnyFilterGroup { get }
}
