// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct ListAuthenticationsResponse: Codable, JSONEncodable {
    public var authentications: [Authentication]
    public var pagination: Pagination

    public init(authentications: [Authentication], pagination: Pagination) {
        self.authentications = authentications
        self.pagination = pagination
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case authentications
        case pagination
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.authentications, forKey: .authentications)
        try container.encode(self.pagination, forKey: .pagination)
    }
}

extension ListAuthenticationsResponse: Equatable {
    public static func ==(lhs: ListAuthenticationsResponse, rhs: ListAuthenticationsResponse) -> Bool {
        lhs.authentications == rhs.authentications &&
            lhs.pagination == rhs.pagination
    }
}

extension ListAuthenticationsResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.authentications.hashValue)
        hasher.combine(self.pagination.hashValue)
    }
}
