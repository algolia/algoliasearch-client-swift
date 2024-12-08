// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Facet to use as category.
public struct Facet: Codable, JSONEncodable {
    /// Facet name.
    public var attribute: String?
    /// Number of suggestions.
    public var amount: Int?

    public init(attribute: String? = nil, amount: Int? = nil) {
        self.attribute = attribute
        self.amount = amount
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case attribute
        case amount
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.attribute, forKey: .attribute)
        try container.encodeIfPresent(self.amount, forKey: .amount)
    }
}

extension Facet: Equatable {
    public static func ==(lhs: Facet, rhs: Facet) -> Bool {
        lhs.attribute == rhs.attribute &&
            lhs.amount == rhs.amount
    }
}

extension Facet: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.attribute?.hashValue)
        hasher.combine(self.amount?.hashValue)
    }
}
