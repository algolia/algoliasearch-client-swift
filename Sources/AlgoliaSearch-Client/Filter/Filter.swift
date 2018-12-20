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
    func build() -> String
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
    public func build() -> String {
        return isInverted ? "NOT \(expression)" : expression
    }

    public mutating func not(value: Bool = true) {
        isInverted = value
    }
}

public struct FilterFacet: Filter, Hashable {

    // TODO: The getter of valueType is a bit heavy, but we want to keep the context of the type used in the init (bool, float, string).
    // Maybe use generics with restricted types.
    public enum ValueType: CustomStringConvertible, Hashable {
        case string(String)
        case float(Float)
        case bool(Bool)

        public var description: String {
            switch self {
            case .string(let value):
                return value
            case .bool(let value):
                return "\(value)"
            case .float(let value):
                return "\(value)"
            }
        }
    }

    public let attribute: Attribute
    public let value: ValueType
    public var isInverted: Bool
    
    public let expression: String
    
    init(attribute: Attribute, value: ValueType, isInverted: Bool) {
        self.attribute = attribute
        self.isInverted = isInverted
        self.value = value
        self.expression = """
        "\(attribute)":"\(value)"
        """
    }

    public init(attribute: Attribute, value: String, isInverted: Bool = false) {
        self.init(attribute: attribute, value: .string(value), isInverted: isInverted)
    }

    public init(attribute: Attribute, value: Bool, isInverted: Bool = false) {
        self.init(attribute: attribute, value: .bool(value), isInverted: isInverted)
    }

    public init(attribute: Attribute, value: Float, isInverted: Bool = false) {
        self.init(attribute: attribute, value: .float(value), isInverted: isInverted)
    }
    
    public func with(_ attribute: Attribute) -> FilterFacet {
        return FilterFacet(attribute: attribute, value: value, isInverted: isInverted)
    }
    
}

public struct FilterTag: Filter, Hashable {
    public let attribute: Attribute = Attribute("_tags")
    public var isInverted: Bool
    public let value: String

    public let expression: String
    
    public init(value: String, isInverted: Bool = false) {
        self.isInverted = isInverted
        self.value = value
        self.expression = """
        "\(attribute)":"\(value)"
        """
    }
    
    public func with(_ attribute: Attribute) -> FilterTag {
        return FilterTag(value: value, isInverted: isInverted)
    }
}

public struct FilterRange: Filter, Hashable {
    public let attribute: Attribute
    public var isInverted: Bool
    public let value: Range<Float>

    public let expression: String
    
    public init(attribute: Attribute, range: Range<Float>, isInverted: Bool = false) {
        self.attribute = attribute
        self.isInverted = isInverted
        self.value = range
        self.expression = """
        "\(attribute)":\(range.lowerBound) TO \(range.upperBound)
        """
    }
    
    public func with(_ attribute: Attribute) -> FilterRange {
        return FilterRange(attribute: attribute, range: value, isInverted: isInverted)
    }
}

public struct FilterComparison: Filter, Hashable {
    public let attribute: Attribute
    public var isInverted: Bool
    public let value: Float

    public let expression: String
    
    public let `operator`: NumericOperator
    
    public init(attribute: Attribute, `operator`: NumericOperator, value: Float, isInverted: Bool = false) {
        self.attribute = attribute
        self.isInverted = isInverted
        self.value = value
        self.operator = `operator`
        self.expression = """
        "\(attribute)" \(`operator`.rawValue) \(value)
        """
    }
    
    public func with(_ attribute: Attribute) -> FilterComparison {
        return FilterComparison(attribute: attribute, operator: `operator`, value: value, isInverted: isInverted)
    }

}
