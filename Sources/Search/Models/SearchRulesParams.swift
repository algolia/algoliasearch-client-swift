// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

/// Rules search parameters.
public struct SearchRulesParams: Codable, JSONEncodable {
    /// Search query for rules.
    public var query: String?
    public var anchoring: SearchAnchoring?
    /// Only return rules that match the context (exact match).
    public var context: String?
    /// Requested page of the API response.  Algolia uses `page` and `hitsPerPage` to control how search results are
    /// displayed
    /// ([paginated](https://www.algolia.com/doc/guides/building-search-ui/ui-and-ux-patterns/pagination/js/)).  -
    /// `hitsPerPage`: sets the number of search results (_hits_) displayed per page. - `page`: specifies the page
    /// number of the search results you want to retrieve. Page numbering starts at 0, so the first page is `page=0`,
    /// the second is `page=1`, and so on.  For example, to display 10 results per page starting from the third page,
    /// set `hitsPerPage` to 10 and `page` to 2.
    public var page: Int?
    /// Maximum number of hits per page.  Algolia uses `page` and `hitsPerPage` to control how search results are
    /// displayed
    /// ([paginated](https://www.algolia.com/doc/guides/building-search-ui/ui-and-ux-patterns/pagination/js/)).  -
    /// `hitsPerPage`: sets the number of search results (_hits_) displayed per page. - `page`: specifies the page
    /// number of the search results you want to retrieve. Page numbering starts at 0, so the first page is `page=0`,
    /// the second is `page=1`, and so on.  For example, to display 10 results per page starting from the third page,
    /// set `hitsPerPage` to 10 and `page` to 2.
    public var hitsPerPage: Int?
    /// If `true`, return only enabled rules. If `false`, return only inactive rules. By default, _all_ rules are
    /// returned.
    public var enabled: Bool?

    public init(
        query: String? = nil,
        anchoring: SearchAnchoring? = nil,
        context: String? = nil,
        page: Int? = nil,
        hitsPerPage: Int? = nil,
        enabled: Bool? = nil
    ) {
        self.query = query
        self.anchoring = anchoring
        self.context = context
        self.page = page
        self.hitsPerPage = hitsPerPage
        self.enabled = enabled
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case query
        case anchoring
        case context
        case page
        case hitsPerPage
        case enabled
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.query, forKey: .query)
        try container.encodeIfPresent(self.anchoring, forKey: .anchoring)
        try container.encodeIfPresent(self.context, forKey: .context)
        try container.encodeIfPresent(self.page, forKey: .page)
        try container.encodeIfPresent(self.hitsPerPage, forKey: .hitsPerPage)
        try container.encodeIfPresent(self.enabled, forKey: .enabled)
    }
}

extension SearchRulesParams: Equatable {
    public static func ==(lhs: SearchRulesParams, rhs: SearchRulesParams) -> Bool {
        lhs.query == rhs.query &&
            lhs.anchoring == rhs.anchoring &&
            lhs.context == rhs.context &&
            lhs.page == rhs.page &&
            lhs.hitsPerPage == rhs.hitsPerPage &&
            lhs.enabled == rhs.enabled
    }
}

extension SearchRulesParams: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.query?.hashValue)
        hasher.combine(self.anchoring?.hashValue)
        hasher.combine(self.context?.hashValue)
        hasher.combine(self.page?.hashValue)
        hasher.combine(self.hitsPerPage?.hashValue)
        hasher.combine(self.enabled?.hashValue)
    }
}
