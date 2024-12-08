// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// API response for creating a new destination.
public struct DestinationCreateResponse: Codable, JSONEncodable {
    /// Universally unique identifier (UUID) of a destination resource.
    public var destinationID: String
    /// Descriptive name for the resource.
    public var name: String
    /// Date of creation in RFC 3339 format.
    public var createdAt: String

    public init(destinationID: String, name: String, createdAt: String) {
        self.destinationID = destinationID
        self.name = name
        self.createdAt = createdAt
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case destinationID
        case name
        case createdAt
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.destinationID, forKey: .destinationID)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.createdAt, forKey: .createdAt)
    }
}

extension DestinationCreateResponse: Equatable {
    public static func ==(lhs: DestinationCreateResponse, rhs: DestinationCreateResponse) -> Bool {
        lhs.destinationID == rhs.destinationID &&
            lhs.name == rhs.name &&
            lhs.createdAt == rhs.createdAt
    }
}

extension DestinationCreateResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.destinationID.hashValue)
        hasher.combine(self.name.hashValue)
        hasher.combine(self.createdAt.hashValue)
    }
}
