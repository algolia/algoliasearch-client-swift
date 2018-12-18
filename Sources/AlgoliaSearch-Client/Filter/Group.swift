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
    let isConjunctive: Bool
    let name: String

    init<F>(_ group: Group<F>) where F: Filter {
        self.hashValue = group.hashValue
        switch group {
        case .and(let name):
            isConjunctive = true
            self.name = name
        case .or(let name):
            isConjunctive = false
            self.name = name
        }
    }

}
