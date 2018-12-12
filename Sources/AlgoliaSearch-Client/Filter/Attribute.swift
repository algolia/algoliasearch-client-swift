//
//  Attribute.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 10/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public class Attribute: CustomStringConvertible {
    var name: String

    init(_ name: String) {
        self.name = name
    }

    public var description: String { return name }
}
