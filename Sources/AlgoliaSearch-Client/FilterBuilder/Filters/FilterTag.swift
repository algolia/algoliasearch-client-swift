//
//  FilterTag.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 27/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public struct FilterTag: Filter, Hashable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public let attribute: Attribute = .tags
    public var isInverted: Bool
    public let value: String
    
    public let expression: String
    
    public init(stringLiteral string: String) {
        self.init(value: string, isInverted: false)
    }
    
    public init(value: String, isInverted: Bool = false) {
        self.isInverted = isInverted
        self.value = value
        self.expression = """
        "\(attribute)":"\(value)"
        """
    }
    
    public func replacingAttribute(by attribute: Attribute) -> FilterTag {
        return FilterTag(value: value, isInverted: isInverted)
    }
}
