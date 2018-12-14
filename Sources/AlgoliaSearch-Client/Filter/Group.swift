//
//  Group.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 14/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public enum Group<F: Filter>: Hashable {
    case and(String)
    case or(String)
}

struct AnyGroup: Hashable {

    let hashValue: Int

    init<F>(_ group: Group<F>) where F: Filter {
        self.hashValue = group.hashValue
    }

}
