// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Rule metadata.
public struct RuleMetadata: Codable, JSONEncodable {
    /// Date and time when the object was updated, in RFC 3339 format.
    public var lastUpdate: String?

    public init(lastUpdate: String? = nil) {
        self.lastUpdate = lastUpdate
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case lastUpdate
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.lastUpdate, forKey: .lastUpdate)
    }
}

extension RuleMetadata: Equatable {
    public static func ==(lhs: RuleMetadata, rhs: RuleMetadata) -> Bool {
        lhs.lastUpdate == rhs.lastUpdate
    }
}

extension RuleMetadata: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.lastUpdate?.hashValue)
    }
}
