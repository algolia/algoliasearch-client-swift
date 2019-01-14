//
//  Filter.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 07/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public protocol Filter: Hashable {

    var attribute: Attribute { get }
    var isInverted: Bool { get set }

    var expression: String { get }

    mutating func not(value: Bool)
    func build(ignoringInversion: Bool) -> String
    func with(_ attribute: Attribute) -> Self
}

struct AnyFilter: Filter {

    let attribute: Attribute
    var isInverted: Bool
    
    let expression: String
    
    private let withAttribute: (Attribute) -> AnyFilter

    init<F: Filter>(_ filter: F) {
        self.attribute = filter.attribute
        self.isInverted = filter.isInverted
        self.expression = filter.expression
        self.withAttribute = { AnyFilter(filter.with($0)) }
    }
    
    func with(_ attribute: Attribute) -> AnyFilter {
        return withAttribute(attribute)
    }
    
    var hashValue: Int {
        var hasher = Hasher()
        attribute.hash(into: &hasher)
        isInverted.hash(into: &hasher)
        expression.hash(into: &hasher)
        return hasher.finalize()
    }
    
    static func == (lhs: AnyFilter, rhs: AnyFilter) -> Bool {
        return lhs.attribute == rhs.attribute &&
            lhs.isInverted == rhs.isInverted &&
            lhs.expression == rhs.expression
    }
    
}

extension Filter {
    public func build(ignoringInversion: Bool = false) -> String {
        if !isInverted || ignoringInversion {
            return expression
        } else {
            return "NOT \(expression)"
        }
    }

    public mutating func not(value: Bool = true) {
        isInverted = value
    }
}
