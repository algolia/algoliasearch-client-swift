// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Describes how a field should be resolved by applying a set of directives.
public struct MappingFieldDirective: Codable, JSONEncodable {
    /// Destination field key.
    public var fieldKey: String
    /// How the destination field should be resolved from the source.
    public var value: [String: AnyCodable]

    public init(fieldKey: String, value: [String: AnyCodable]) {
        self.fieldKey = fieldKey
        self.value = value
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case fieldKey
        case value
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.fieldKey, forKey: .fieldKey)
        try container.encode(self.value, forKey: .value)
    }
}

extension MappingFieldDirective: Equatable {
    public static func ==(lhs: MappingFieldDirective, rhs: MappingFieldDirective) -> Bool {
        lhs.fieldKey == rhs.fieldKey &&
            lhs.value == rhs.value
    }
}

extension MappingFieldDirective: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.fieldKey.hashValue)
        hasher.combine(self.value.hashValue)
    }
}
