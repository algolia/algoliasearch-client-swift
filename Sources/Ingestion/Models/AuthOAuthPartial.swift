// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Credentials for authenticating with OAuth 2.0.
public struct AuthOAuthPartial: Codable, JSONEncodable {
    /// URL for the OAuth endpoint.
    public var url: String?
    /// Client ID.
    public var clientId: String?
    /// Client secret. This field is `null` in the API response.
    public var clientSecret: String?
    /// OAuth scope.
    public var scope: String?

    public init(url: String? = nil, clientId: String? = nil, clientSecret: String? = nil, scope: String? = nil) {
        self.url = url
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.scope = scope
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case url
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case scope
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.url, forKey: .url)
        try container.encodeIfPresent(self.clientId, forKey: .clientId)
        try container.encodeIfPresent(self.clientSecret, forKey: .clientSecret)
        try container.encodeIfPresent(self.scope, forKey: .scope)
    }
}

extension AuthOAuthPartial: Equatable {
    public static func ==(lhs: AuthOAuthPartial, rhs: AuthOAuthPartial) -> Bool {
        lhs.url == rhs.url &&
            lhs.clientId == rhs.clientId &&
            lhs.clientSecret == rhs.clientSecret &&
            lhs.scope == rhs.scope
    }
}

extension AuthOAuthPartial: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.url?.hashValue)
        hasher.combine(self.clientId?.hashValue)
        hasher.combine(self.clientSecret?.hashValue)
        hasher.combine(self.scope?.hashValue)
    }
}
