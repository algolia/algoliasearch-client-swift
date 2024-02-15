// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

// MARK: - ListClustersResponse

/// Clusters.
public struct ListClustersResponse: Codable, JSONEncodable, Hashable {
    // MARK: Lifecycle

    public init(topUsers: [String]) {
        self.topUsers = topUsers
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case topUsers
    }

    /// Key-value pairs with cluster names as keys and lists of users with the highest number of records per cluster as
    /// values.
    public var topUsers: [String]

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.topUsers, forKey: .topUsers)
    }
}
