//
//  OptionalFilterBuilder.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 27/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public class OptionalFilterBuilder {
    
    public typealias Subbuilder = RestrictedFilterBuilder<FilterFacet>
    
    var subbuilders: [String: Subbuilder]
    
    public init() {
        subbuilders = [:]
    }
    
    public subscript(key: String) -> Subbuilder {
        guard let existingBuilder = subbuilders[key] else {
            let builder = Subbuilder()
            subbuilders[key] = builder
            return builder
        }
        return existingBuilder
    }
    
    public func build() -> [String] {
        return subbuilders
            .sorted { $0.key < $1.key }
            .map { $0.value.build(ignoringInversion: true) }
    }
    
}
