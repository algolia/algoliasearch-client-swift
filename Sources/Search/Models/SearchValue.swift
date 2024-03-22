// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

public struct SearchValue: Codable, JSONEncodable {
    /// Explicit order of facets or facet values.  This setting lets you always show specific facets or facet values at
    /// the top of the list.
    public var order: [String]?
    public var sortRemainingBy: SearchSortRemainingBy?

    public init(order: [String]? = nil, sortRemainingBy: SearchSortRemainingBy? = nil) {
        self.order = order
        self.sortRemainingBy = sortRemainingBy
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case order
        case sortRemainingBy
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.order, forKey: .order)
        try container.encodeIfPresent(self.sortRemainingBy, forKey: .sortRemainingBy)
    }
}
