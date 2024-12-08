// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct TopHitsResponseWithAnalytics: Codable, JSONEncodable {
    /// Most frequent search results with click and conversion metrics.
    public var hits: [TopHitWithAnalytics]

    public init(hits: [TopHitWithAnalytics]) {
        self.hits = hits
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case hits
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.hits, forKey: .hits)
    }
}

extension TopHitsResponseWithAnalytics: Equatable {
    public static func ==(lhs: TopHitsResponseWithAnalytics, rhs: TopHitsResponseWithAnalytics) -> Bool {
        lhs.hits == rhs.hits
    }
}

extension TopHitsResponseWithAnalytics: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.hits.hashValue)
    }
}
