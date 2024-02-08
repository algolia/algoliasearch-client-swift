// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

public struct SearchMethodParams: Codable, JSONEncodable, Hashable {
    public var requests: [SearchQuery]
    public var strategy: SearchStrategy?

    public init(requests: [SearchQuery], strategy: SearchStrategy? = nil) {
        self.requests = requests
        self.strategy = strategy
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case requests
        case strategy
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requests, forKey: .requests)
        try container.encodeIfPresent(strategy, forKey: .strategy)
    }
}