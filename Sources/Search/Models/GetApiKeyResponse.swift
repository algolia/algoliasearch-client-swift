// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct GetApiKeyResponse: Codable, JSONEncodable {
    /// API key.
    public var value: String
    /// Timestamp when the object was created, in milliseconds since the Unix epoch.
    public var createdAt: Int64
    /// Permissions that determine the type of API requests this key can make. The required ACL is listed in each
    /// endpoint's reference. For more information, see [access control
    /// list](https://www.algolia.com/doc/guides/security/api-keys/#access-control-list-acl).
    public var acl: [Acl]
    /// Description of an API key to help you identify this API key.
    public var description: String?
    /// Index names or patterns that this API key can access. By default, an API key can access all indices in the same
    /// application.  You can use leading and trailing wildcard characters (`*`):  - `dev_*` matches all indices
    /// starting with \"dev_\". - `*_dev` matches all indices ending with \"_dev\". - `*_products_*` matches all indices
    /// containing \"_products_\".
    public var indexes: [String]?
    /// Maximum number of results this API key can retrieve in one query. By default, there's no limit.
    public var maxHitsPerQuery: Int?
    /// Maximum number of API requests allowed per IP address or [user
    /// token](https://www.algolia.com/doc/guides/sending-events/concepts/usertoken/) per hour.  If this limit is
    /// reached, the API returns an error with status code `429`. By default, there's no limit.
    public var maxQueriesPerIPPerHour: Int?
    /// Query parameters to add when making API requests with this API key.  To restrict this API key to specific IP
    /// addresses, add the `restrictSources` parameter. You can only add a single source, but you can provide a range of
    /// IP addresses.  Creating an API key fails if the request is made from an IP address outside the restricted range.
    public var queryParameters: String?
    /// Allowed HTTP referrers for this API key.  By default, all referrers are allowed. You can use leading and
    /// trailing wildcard characters (`*`):  - `https://algolia.com/_*` allows all referrers starting with
    /// \"https://algolia.com/\" - `*.algolia.com` allows all referrers ending with \".algolia.com\" - `*algolia.com*`
    /// allows all referrers in the domain \"algolia.com\".  Like all HTTP headers, referrers can be spoofed. Don't rely
    /// on them to secure your data. For more information, see [HTTP referrer
    /// restrictions](https://www.algolia.com/doc/guides/security/security-best-practices/#http-referrers-restrictions).
    public var referers: [String]?
    /// Duration (in seconds) after which the API key expires. By default, API keys don't expire.
    public var validity: Int?

    public init(
        value: String,
        createdAt: Int64,
        acl: [Acl],
        description: String? = nil,
        indexes: [String]? = nil,
        maxHitsPerQuery: Int? = nil,
        maxQueriesPerIPPerHour: Int? = nil,
        queryParameters: String? = nil,
        referers: [String]? = nil,
        validity: Int? = nil
    ) {
        self.value = value
        self.createdAt = createdAt
        self.acl = acl
        self.description = description
        self.indexes = indexes
        self.maxHitsPerQuery = maxHitsPerQuery
        self.maxQueriesPerIPPerHour = maxQueriesPerIPPerHour
        self.queryParameters = queryParameters
        self.referers = referers
        self.validity = validity
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case value
        case createdAt
        case acl
        case description
        case indexes
        case maxHitsPerQuery
        case maxQueriesPerIPPerHour
        case queryParameters
        case referers
        case validity
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: .value)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.acl, forKey: .acl)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.indexes, forKey: .indexes)
        try container.encodeIfPresent(self.maxHitsPerQuery, forKey: .maxHitsPerQuery)
        try container.encodeIfPresent(self.maxQueriesPerIPPerHour, forKey: .maxQueriesPerIPPerHour)
        try container.encodeIfPresent(self.queryParameters, forKey: .queryParameters)
        try container.encodeIfPresent(self.referers, forKey: .referers)
        try container.encodeIfPresent(self.validity, forKey: .validity)
    }
}

extension GetApiKeyResponse: Equatable {
    public static func ==(lhs: GetApiKeyResponse, rhs: GetApiKeyResponse) -> Bool {
        lhs.value == rhs.value &&
            lhs.createdAt == rhs.createdAt &&
            lhs.acl == rhs.acl &&
            lhs.description == rhs.description &&
            lhs.indexes == rhs.indexes &&
            lhs.maxHitsPerQuery == rhs.maxHitsPerQuery &&
            lhs.maxQueriesPerIPPerHour == rhs.maxQueriesPerIPPerHour &&
            lhs.queryParameters == rhs.queryParameters &&
            lhs.referers == rhs.referers &&
            lhs.validity == rhs.validity
    }
}

extension GetApiKeyResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.value.hashValue)
        hasher.combine(self.createdAt.hashValue)
        hasher.combine(self.acl.hashValue)
        hasher.combine(self.description?.hashValue)
        hasher.combine(self.indexes?.hashValue)
        hasher.combine(self.maxHitsPerQuery?.hashValue)
        hasher.combine(self.maxQueriesPerIPPerHour?.hashValue)
        hasher.combine(self.queryParameters?.hashValue)
        hasher.combine(self.referers?.hashValue)
        hasher.combine(self.validity?.hashValue)
    }
}
