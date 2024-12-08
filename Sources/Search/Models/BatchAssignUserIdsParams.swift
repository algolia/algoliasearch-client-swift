// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Assign userID parameters.
public struct BatchAssignUserIdsParams: Codable, JSONEncodable {
    /// Cluster name.
    public var cluster: String
    /// User IDs to assign.
    public var users: [String]

    public init(cluster: String, users: [String]) {
        self.cluster = cluster
        self.users = users
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case cluster
        case users
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.cluster, forKey: .cluster)
        try container.encode(self.users, forKey: .users)
    }
}

extension BatchAssignUserIdsParams: Equatable {
    public static func ==(lhs: BatchAssignUserIdsParams, rhs: BatchAssignUserIdsParams) -> Bool {
        lhs.cluster == rhs.cluster &&
            lhs.users == rhs.users
    }
}

extension BatchAssignUserIdsParams: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.cluster.hashValue)
        hasher.combine(self.users.hashValue)
    }
}
