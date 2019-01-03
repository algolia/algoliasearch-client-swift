//
//  FilterFacet.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 27/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

public struct FilterFacet: Filter, Hashable {
    
    public let attribute: Attribute
    public let value: ValueType
    public var isInverted: Bool
    
    public let expression: String
    
    public init(attribute: Attribute, value: ValueType, isInverted: Bool = false) {
        self.attribute = attribute
        self.isInverted = isInverted
        self.value = value
        self.expression = """
        "\(attribute)":"\(value)"
        """
    }
    
    public init(attribute: Attribute, stringValue: String, isInverted: Bool = false) {
        self.init(attribute: attribute, value: .string(stringValue), isInverted: isInverted)
    }
    
    public init(attribute: Attribute, floatValue: Float, isInverted: Bool = false) {
        self.init(attribute: attribute, value: .float(floatValue), isInverted: isInverted)
    }
    
    public init(attribute: Attribute, boolValue: Bool, isInverted: Bool = false) {
        self.init(attribute: attribute, value: .bool(boolValue), isInverted: isInverted)
    }
    
    public func with(_ attribute: Attribute) -> FilterFacet {
        return FilterFacet(attribute: attribute, value: value, isInverted: isInverted)
    }
    
}

extension FilterFacet: RawRepresentable {

    public typealias RawValue = (Attribute, ValueType)
    
    public init?(rawValue: (Attribute, FilterFacet.ValueType)) {
        self.init(attribute: rawValue.0, value: rawValue.1)
    }
    
    public var rawValue: (Attribute, FilterFacet.ValueType) {
        return (attribute, value)
    }
    
}

extension FilterFacet {
    
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
    
}

extension FilterFacet.ValueType: ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
    
}

extension FilterFacet.ValueType: ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = Float
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .float(value)
    }
    
}

extension FilterFacet.ValueType: ExpressibleByStringLiteral {
    
    public typealias StringLiterlalType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
}

extension FilterFacet.ValueType: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .float(Float(value))
    }
    
}
