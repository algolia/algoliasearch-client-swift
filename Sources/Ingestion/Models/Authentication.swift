// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Resource representing the information required to authenticate with a source or a destination.
public struct Authentication: Codable, JSONEncodable {
    /// Universally unique identifier (UUID) of an authentication resource.
    public var authenticationID: String
    public var type: AuthenticationType
    /// Descriptive name for the resource.
    public var name: String
    public var platform: Platform?
    public var input: AuthInputPartial
    /// Date of creation in RFC 3339 format.
    public var createdAt: String
    /// Date of last update in RFC 3339 format.
    public var updatedAt: String?

    public init(
        authenticationID: String,
        type: AuthenticationType,
        name: String,
        platform: Platform? = nil,
        input: AuthInputPartial,
        createdAt: String,
        updatedAt: String? = nil
    ) {
        self.authenticationID = authenticationID
        self.type = type
        self.name = name
        self.platform = platform
        self.input = input
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case authenticationID
        case type
        case name
        case platform
        case input
        case createdAt
        case updatedAt
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.authenticationID, forKey: .authenticationID)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.platform, forKey: .platform)
        try container.encode(self.input, forKey: .input)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encodeIfPresent(self.updatedAt, forKey: .updatedAt)
    }
}

extension Authentication: Equatable {
    public static func ==(lhs: Authentication, rhs: Authentication) -> Bool {
        lhs.authenticationID == rhs.authenticationID &&
            lhs.type == rhs.type &&
            lhs.name == rhs.name &&
            lhs.platform == rhs.platform &&
            lhs.input == rhs.input &&
            lhs.createdAt == rhs.createdAt &&
            lhs.updatedAt == rhs.updatedAt
    }
}

extension Authentication: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.authenticationID.hashValue)
        hasher.combine(self.type.hashValue)
        hasher.combine(self.name.hashValue)
        hasher.combine(self.platform?.hashValue)
        hasher.combine(self.input.hashValue)
        hasher.combine(self.createdAt.hashValue)
        hasher.combine(self.updatedAt?.hashValue)
    }
}
