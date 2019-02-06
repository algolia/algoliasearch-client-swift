//
//  OptionalFilterBuilder.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 27/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// Convenient builder of optional filters
/// For better understanding of optional filters, please read the documentation linked below:
/// [Documentation](https:www.algolia.com/doc/api-reference/api-parameters/optionalFilters/)

public class OptionalFilterBuilder {
    
    /// Type representing the output array unit type
    /// Either a string (a part of conjunction), or a list of string (disjunction of filters)
    public enum Output {
        case single(String)
        case list([String])
        
        var rawValue: Any {
            switch self {
            case .single(let element):
                return element
            case .list(let elements):
                return elements
            }
        }
    }

    let facetFilterBuilder: SpecializedFilterBuilder<FilterFacet>
    
    public init() {
        facetFilterBuilder = SpecializedFilterBuilder<FilterFacet>()
    }
    
    public init(_ optionalFilterBuilder: OptionalFilterBuilder) {
        self.facetFilterBuilder = optionalFilterBuilder.facetFilterBuilder
    }
    
    public subscript(group: AndFilterGroup) -> SpecializedAndGroupProxy<FilterFacet> {
        return facetFilterBuilder[group]
    }
    
    public subscript(group: OrFilterGroup<FilterFacet>) -> OrGroupProxy<FilterFacet> {
        return facetFilterBuilder[group]
    }
    
    /// Constructs intermediate representation of optional filters
    /// The raw representation can be accessed using `rawValue` computed variable.
    public func build() -> [Output]? {
        
        guard !facetFilterBuilder.isEmpty else { return nil }
        
        var result: [Output] = []
        
        facetFilterBuilder.groups.keys.sorted {
            $0.name != $1.name ? $0.name < $1.name : $0.isConjunctive
        }.forEach { group in
            let filtersExpressionForGroup = (facetFilterBuilder.groups[group] ?? [])
                .sorted { $0.expression < $1.expression }
                .map { $0.build(ignoringInversion: true) }
            if group.isConjunctive || filtersExpressionForGroup.count == 1 {
                filtersExpressionForGroup.forEach { result.append(.single($0)) }
            } else {
                result.append(.list(filtersExpressionForGroup))
            }
        }
        
        return result
    }
    
}

extension Sequence where Element == OptionalFilterBuilder.Output {
    
    var rawValue: [Any] {
        return self.map { $0.rawValue }
    }
    
}
