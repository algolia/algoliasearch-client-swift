// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct ListApiKeysResponse: Codable, JSONEncodable {
    /// API keys.
    public var keys: [GetApiKeyResponse]

    public init(keys: [GetApiKeyResponse]) {
        self.keys = keys
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case keys
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.keys, forKey: .keys)
    }
}

extension ListApiKeysResponse: Equatable {
    public static func ==(lhs: ListApiKeysResponse, rhs: ListApiKeysResponse) -> Bool {
        lhs.keys == rhs.keys
    }
}

extension ListApiKeysResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.keys.hashValue)
    }
}
