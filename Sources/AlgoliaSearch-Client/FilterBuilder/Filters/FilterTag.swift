//
//  FilterTag.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 27/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// Defines tag filter
///[Documentation](https:www.algolia.com/doc/guides/managing-results/refine-results/filtering/how-to/filter-by-tags/)
public struct FilterTag: Filter, Hashable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public let attribute: Attribute = .tags
    public var isNegated: Bool
    public let value: String
    
    public let expression: String
    
    public init(stringLiteral string: String) {
        self.init(value: string, isNegated: false)
    }
    
    public init(value: String, isNegated: Bool = false) {
        self.isNegated = isNegated
        self.value = value
        self.expression = """
        "\(attribute)":"\(value)"
        """
    }
    
    public func replacingAttribute(by attribute: Attribute) -> FilterTag {
        return FilterTag(value: value, isNegated: isNegated)
    }
}
