// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Request body for searching for authentication resources.
public struct AuthenticationSearch: Codable, JSONEncodable {
    public var authenticationIDs: [String]

    public init(authenticationIDs: [String]) {
        self.authenticationIDs = authenticationIDs
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case authenticationIDs
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.authenticationIDs, forKey: .authenticationIDs)
    }
}

extension AuthenticationSearch: Equatable {
    public static func ==(lhs: AuthenticationSearch, rhs: AuthenticationSearch) -> Bool {
        lhs.authenticationIDs == rhs.authenticationIDs
    }
}

extension AuthenticationSearch: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.authenticationIDs.hashValue)
    }
}
