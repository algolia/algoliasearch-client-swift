// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Parameters to apply to this search.  You can use all search parameters, plus special `automaticFacetFilters`,
/// `automaticOptionalFacetFilters`, and `query`.
public struct SearchParams: Codable, JSONEncodable {
    public var query: SearchConsequenceQuery?
    public var automaticFacetFilters: SearchAutomaticFacetFilters?
    public var automaticOptionalFacetFilters: SearchAutomaticFacetFilters?
    public var renderingContent: SearchRenderingContent?

    public init(
        query: SearchConsequenceQuery? = nil,
        automaticFacetFilters: SearchAutomaticFacetFilters? = nil,
        automaticOptionalFacetFilters: SearchAutomaticFacetFilters? = nil,
        renderingContent: SearchRenderingContent? = nil
    ) {
        self.query = query
        self.automaticFacetFilters = automaticFacetFilters
        self.automaticOptionalFacetFilters = automaticOptionalFacetFilters
        self.renderingContent = renderingContent
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case query
        case automaticFacetFilters
        case automaticOptionalFacetFilters
        case renderingContent
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.query, forKey: .query)
        try container.encodeIfPresent(self.automaticFacetFilters, forKey: .automaticFacetFilters)
        try container.encodeIfPresent(self.automaticOptionalFacetFilters, forKey: .automaticOptionalFacetFilters)
        try container.encodeIfPresent(self.renderingContent, forKey: .renderingContent)
    }
}

extension SearchParams: Equatable {
    public static func ==(lhs: SearchParams, rhs: SearchParams) -> Bool {
        lhs.query == rhs.query &&
            lhs.automaticFacetFilters == rhs.automaticFacetFilters &&
            lhs.automaticOptionalFacetFilters == rhs.automaticOptionalFacetFilters &&
            lhs.renderingContent == rhs.renderingContent
    }
}

extension SearchParams: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.query?.hashValue)
        hasher.combine(self.automaticFacetFilters?.hashValue)
        hasher.combine(self.automaticOptionalFacetFilters?.hashValue)
        hasher.combine(self.renderingContent?.hashValue)
    }
}
