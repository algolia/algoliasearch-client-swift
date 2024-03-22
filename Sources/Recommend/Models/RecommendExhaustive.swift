// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

/// Whether certain properties of the search response are calculated exhaustive (exact) or approximated.
public struct RecommendExhaustive: Codable, JSONEncodable {
    /// Whether the facet count is exhaustive (`true`) or approximate (`false`). See the [related discussion](https://support.algolia.com/hc/en-us/articles/4406975248145-Why-are-my-facet-and-hit-counts-not-accurate-).
    public var facetsCount: Bool?
    /// The value is `false` if not all facet values are retrieved.
    public var facetValues: Bool?
    /// Whether the `nbHits` is exhaustive (`true`) or approximate (`false`). When the query takes more than 50ms to be
    /// processed, the engine makes an approximation. This can happen when using complex filters on millions of records,
    /// when typo-tolerance was not exhaustive, or when enough hits have been retrieved (for example, after the engine
    /// finds 10,000 exact matches). `nbHits` is reported as non-exhaustive whenever an approximation is made, even if
    /// the approximation didn’t, in the end, impact the exhaustivity of the query.
    public var nbHits: Bool?
    /// Rules matching exhaustivity. The value is `false` if rules were enable for this query, and could not be fully
    /// processed due a timeout. This is generally caused by the number of alternatives (such as typos) which is too
    /// large.
    public var rulesMatch: Bool?
    /// Whether the typo search was exhaustive (`true`) or approximate (`false`). An approximation is done when the typo
    /// search query part takes more than 10% of the query budget (ie. 5ms by default) to be processed (this can happen
    /// when a lot of typo alternatives exist for the query). This field will not be included when typo-tolerance is
    /// entirely disabled.
    public var typo: Bool?

    public init(
        facetsCount: Bool? = nil,
        facetValues: Bool? = nil,
        nbHits: Bool? = nil,
        rulesMatch: Bool? = nil,
        typo: Bool? = nil
    ) {
        self.facetsCount = facetsCount
        self.facetValues = facetValues
        self.nbHits = nbHits
        self.rulesMatch = rulesMatch
        self.typo = typo
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case facetsCount
        case facetValues
        case nbHits
        case rulesMatch
        case typo
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.facetsCount, forKey: .facetsCount)
        try container.encodeIfPresent(self.facetValues, forKey: .facetValues)
        try container.encodeIfPresent(self.nbHits, forKey: .nbHits)
        try container.encodeIfPresent(self.rulesMatch, forKey: .rulesMatch)
        try container.encodeIfPresent(self.typo, forKey: .typo)
    }
}
