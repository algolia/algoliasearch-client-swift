//
//  Filter.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 07/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public protocol Filter {
    var attribute: Attribute { get }
    var negates: Bool { get }

    var expression: String { get }

    func build() -> String
}

extension Filter {
    public func build() -> String {
        return negates ? "NOT \(expression)" : expression
    }
}

public class FacetFilter: Filter {
    public var attribute: Attribute
    public var negates: Bool

    public var expression: String

    public init(attribute: Attribute, value: String, negates: Bool = false) {
        self.attribute = attribute
        self.negates = negates

        self.expression = "\(attribute):\(value)"
    }
}





public class FilterRange: Filter {

    init(attribute: Attribute, negates: Bool) {
        self.attribute = attribute
        self.negates = negates
        self.expression = "" // TODO
    }

    public var attribute: Attribute

    public var negates: Bool

    public var expression: String

}

public class FilterComparison: Filter {

    init(attribute: Attribute, negates: Bool) {
        self.attribute = attribute
        self.negates = negates
        self.expression = "" // TODO
    }

    public var attribute: Attribute

    public var negates: Bool

    public var expression: String

}
