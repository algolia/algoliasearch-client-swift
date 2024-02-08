// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

public struct FacetHits: Codable, JSONEncodable, Hashable {
    /** Facet value. */
    public var value: String
    /** Markup text with `facetQuery` matches highlighted. */
    public var highlighted: String
    /** Number of records containing this facet value. This takes into account the extra search parameters specified in the query. Like for a regular search query, the [counts may not be exhaustive](https://support.algolia.com/hc/en-us/articles/4406975248145-Why-are-my-facet-and-hit-counts-not-accurate-). */
    public var count: Int

    public init(value: String, highlighted: String, count: Int) {
        self.value = value
        self.highlighted = highlighted
        self.count = count
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case value
        case highlighted
        case count
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(highlighted, forKey: .highlighted)
        try container.encode(count, forKey: .count)
    }
}