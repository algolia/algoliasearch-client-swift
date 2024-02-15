// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

// MARK: - RecommendedForYouQueryParameters

public struct RecommendedForYouQueryParameters: Codable, JSONEncodable, Hashable {
    // MARK: Lifecycle

    public init(
        query: String? = nil,
        similarQuery: String? = nil,
        filters: String? = nil,
        facetFilters: FacetFilters? = nil,
        optionalFilters: OptionalFilters? = nil,
        numericFilters: NumericFilters? = nil,
        tagFilters: TagFilters? = nil,
        sumOrFiltersScores: Bool? = nil,
        restrictSearchableAttributes: [String]? = nil,
        facets: [String]? = nil,
        facetingAfterDistinct: Bool? = nil,
        page: Int? = nil,
        offset: Int? = nil,
        length: Int? = nil,
        aroundLatLng: String? = nil,
        aroundLatLngViaIP: Bool? = nil,
        aroundRadius: AroundRadius? = nil,
        aroundPrecision: AroundPrecision? = nil,
        minimumAroundRadius: Int? = nil,
        insideBoundingBox: [[Double]]? = nil,
        insidePolygon: [[Double]]? = nil,
        naturalLanguages: [String]? = nil,
        ruleContexts: [String]? = nil,
        personalizationImpact: Int? = nil,
        userToken: String,
        getRankingInfo: Bool? = nil,
        explain: [String]? = nil,
        synonyms: Bool? = nil,
        clickAnalytics: Bool? = nil,
        analytics: Bool? = nil,
        analyticsTags: [String]? = nil,
        percentileComputation: Bool? = nil,
        enableABTest: Bool? = nil,
        attributesForFaceting: [String]? = nil,
        attributesToRetrieve: [String]? = nil,
        ranking: [String]? = nil,
        customRanking: [String]? = nil,
        relevancyStrictness: Int? = nil,
        attributesToHighlight: [String]? = nil,
        attributesToSnippet: [String]? = nil,
        highlightPreTag: String? = nil,
        highlightPostTag: String? = nil,
        snippetEllipsisText: String? = nil,
        restrictHighlightAndSnippetArrays: Bool? = nil,
        hitsPerPage: Int? = nil,
        minWordSizefor1Typo: Int? = nil,
        minWordSizefor2Typos: Int? = nil,
        typoTolerance: TypoTolerance? = nil,
        allowTyposOnNumericTokens: Bool? = nil,
        disableTypoToleranceOnAttributes: [String]? = nil,
        ignorePlurals: IgnorePlurals? = nil,
        removeStopWords: RemoveStopWords? = nil,
        keepDiacriticsOnCharacters: String? = nil,
        queryLanguages: [String]? = nil,
        decompoundQuery: Bool? = nil,
        enableRules: Bool? = nil,
        enablePersonalization: Bool? = nil,
        queryType: QueryType? = nil,
        removeWordsIfNoResults: RemoveWordsIfNoResults? = nil,
        mode: Mode? = nil,
        semanticSearch: SemanticSearch? = nil,
        advancedSyntax: Bool? = nil,
        optionalWords: [String]? = nil,
        disableExactOnAttributes: [String]? = nil,
        exactOnSingleWordQuery: ExactOnSingleWordQuery? = nil,
        alternativesAsExact: [AlternativesAsExact]? = nil,
        advancedSyntaxFeatures: [AdvancedSyntaxFeatures]? = nil,
        distinct: Distinct? = nil,
        replaceSynonymsInHighlight: Bool? = nil,
        minProximity: Int? = nil,
        responseFields: [String]? = nil,
        maxFacetHits: Int? = nil,
        maxValuesPerFacet: Int? = nil,
        sortFacetValuesBy: String? = nil,
        attributeCriteriaComputedByMinProximity: Bool? = nil,
        renderingContent: RenderingContent? = nil,
        enableReRanking: Bool? = nil,
        reRankingApplyFilter: ReRankingApplyFilter? = nil
    ) {
        self.query = query
        self.similarQuery = similarQuery
        self.filters = filters
        self.facetFilters = facetFilters
        self.optionalFilters = optionalFilters
        self.numericFilters = numericFilters
        self.tagFilters = tagFilters
        self.sumOrFiltersScores = sumOrFiltersScores
        self.restrictSearchableAttributes = restrictSearchableAttributes
        self.facets = facets
        self.facetingAfterDistinct = facetingAfterDistinct
        self.page = page
        self.offset = offset
        self.length = length
        self.aroundLatLng = aroundLatLng
        self.aroundLatLngViaIP = aroundLatLngViaIP
        self.aroundRadius = aroundRadius
        self.aroundPrecision = aroundPrecision
        self.minimumAroundRadius = minimumAroundRadius
        self.insideBoundingBox = insideBoundingBox
        self.insidePolygon = insidePolygon
        self.naturalLanguages = naturalLanguages
        self.ruleContexts = ruleContexts
        self.personalizationImpact = personalizationImpact
        self.userToken = userToken
        self.getRankingInfo = getRankingInfo
        self.explain = explain
        self.synonyms = synonyms
        self.clickAnalytics = clickAnalytics
        self.analytics = analytics
        self.analyticsTags = analyticsTags
        self.percentileComputation = percentileComputation
        self.enableABTest = enableABTest
        self.attributesForFaceting = attributesForFaceting
        self.attributesToRetrieve = attributesToRetrieve
        self.ranking = ranking
        self.customRanking = customRanking
        self.relevancyStrictness = relevancyStrictness
        self.attributesToHighlight = attributesToHighlight
        self.attributesToSnippet = attributesToSnippet
        self.highlightPreTag = highlightPreTag
        self.highlightPostTag = highlightPostTag
        self.snippetEllipsisText = snippetEllipsisText
        self.restrictHighlightAndSnippetArrays = restrictHighlightAndSnippetArrays
        self.hitsPerPage = hitsPerPage
        self.minWordSizefor1Typo = minWordSizefor1Typo
        self.minWordSizefor2Typos = minWordSizefor2Typos
        self.typoTolerance = typoTolerance
        self.allowTyposOnNumericTokens = allowTyposOnNumericTokens
        self.disableTypoToleranceOnAttributes = disableTypoToleranceOnAttributes
        self.ignorePlurals = ignorePlurals
        self.removeStopWords = removeStopWords
        self.keepDiacriticsOnCharacters = keepDiacriticsOnCharacters
        self.queryLanguages = queryLanguages
        self.decompoundQuery = decompoundQuery
        self.enableRules = enableRules
        self.enablePersonalization = enablePersonalization
        self.queryType = queryType
        self.removeWordsIfNoResults = removeWordsIfNoResults
        self.mode = mode
        self.semanticSearch = semanticSearch
        self.advancedSyntax = advancedSyntax
        self.optionalWords = optionalWords
        self.disableExactOnAttributes = disableExactOnAttributes
        self.exactOnSingleWordQuery = exactOnSingleWordQuery
        self.alternativesAsExact = alternativesAsExact
        self.advancedSyntaxFeatures = advancedSyntaxFeatures
        self.distinct = distinct
        self.replaceSynonymsInHighlight = replaceSynonymsInHighlight
        self.minProximity = minProximity
        self.responseFields = responseFields
        self.maxFacetHits = maxFacetHits
        self.maxValuesPerFacet = maxValuesPerFacet
        self.sortFacetValuesBy = sortFacetValuesBy
        self.attributeCriteriaComputedByMinProximity = attributeCriteriaComputedByMinProximity
        self.renderingContent = renderingContent
        self.enableReRanking = enableReRanking
        self.reRankingApplyFilter = reRankingApplyFilter
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case query
        case similarQuery
        case filters
        case facetFilters
        case optionalFilters
        case numericFilters
        case tagFilters
        case sumOrFiltersScores
        case restrictSearchableAttributes
        case facets
        case facetingAfterDistinct
        case page
        case offset
        case length
        case aroundLatLng
        case aroundLatLngViaIP
        case aroundRadius
        case aroundPrecision
        case minimumAroundRadius
        case insideBoundingBox
        case insidePolygon
        case naturalLanguages
        case ruleContexts
        case personalizationImpact
        case userToken
        case getRankingInfo
        case explain
        case synonyms
        case clickAnalytics
        case analytics
        case analyticsTags
        case percentileComputation
        case enableABTest
        case attributesForFaceting
        case attributesToRetrieve
        case ranking
        case customRanking
        case relevancyStrictness
        case attributesToHighlight
        case attributesToSnippet
        case highlightPreTag
        case highlightPostTag
        case snippetEllipsisText
        case restrictHighlightAndSnippetArrays
        case hitsPerPage
        case minWordSizefor1Typo
        case minWordSizefor2Typos
        case typoTolerance
        case allowTyposOnNumericTokens
        case disableTypoToleranceOnAttributes
        case ignorePlurals
        case removeStopWords
        case keepDiacriticsOnCharacters
        case queryLanguages
        case decompoundQuery
        case enableRules
        case enablePersonalization
        case queryType
        case removeWordsIfNoResults
        case mode
        case semanticSearch
        case advancedSyntax
        case optionalWords
        case disableExactOnAttributes
        case exactOnSingleWordQuery
        case alternativesAsExact
        case advancedSyntaxFeatures
        case distinct
        case replaceSynonymsInHighlight
        case minProximity
        case responseFields
        case maxFacetHits
        case maxValuesPerFacet
        case sortFacetValuesBy
        case attributeCriteriaComputedByMinProximity
        case renderingContent
        case enableReRanking
        case reRankingApplyFilter
    }

    /// Text to search for in an index.
    public var query: String?
    /// Overrides the query parameter and performs a more generic search.
    public var similarQuery: String?
    /// [Filter](https://www.algolia.com/doc/guides/managing-results/refine-results/filtering/) the query with numeric,
    /// facet, or tag filters.
    public var filters: String?
    public var facetFilters: FacetFilters?
    public var optionalFilters: OptionalFilters?
    public var numericFilters: NumericFilters?
    public var tagFilters: TagFilters?
    /// Determines how to calculate [filter scores](https://www.algolia.com/doc/guides/managing-results/refine-results/filtering/in-depth/filter-scoring/#accumulating-scores-with-sumorfiltersscores).
    /// If `false`, maximum score is kept. If `true`, score is summed.
    public var sumOrFiltersScores: Bool?
    /// Restricts a query to only look at a subset of your [searchable
    /// attributes](https://www.algolia.com/doc/guides/managing-results/must-do/searchable-attributes/).
    public var restrictSearchableAttributes: [String]?
    /// Returns [facets](https://www.algolia.com/doc/guides/managing-results/refine-results/faceting/#contextual-facet-values-and-counts),
    /// their facet values, and the number of matching facet values.
    public var facets: [String]?
    /// Forces faceting to be applied after
    /// [de-duplication](https://www.algolia.com/doc/guides/managing-results/refine-results/grouping/) (with the
    /// distinct feature). Alternatively, the `afterDistinct`
    /// [modifier](https://www.algolia.com/doc/api-reference/api-parameters/attributesForFaceting/#modifiers) of
    /// `attributesForFaceting` allows for more granular control.
    public var facetingAfterDistinct: Bool?
    /// Page to retrieve (the first page is `0`, not `1`).
    public var page: Int?
    /// Specifies the offset of the first hit to return. > **Note**: Using `page` and `hitsPerPage` is the recommended
    /// method for [paging
    /// results](https://www.algolia.com/doc/guides/building-search-ui/ui-and-ux-patterns/pagination/js/). However, you
    /// can use `offset` and `length` to implement [an alternative approach to paging](https://www.algolia.com/doc/guides/building-search-ui/ui-and-ux-patterns/pagination/js/#retrieving-a-subset-of-records-with-offset-and-length).
    public var offset: Int?
    /// Sets the number of hits to retrieve (for use with `offset`). > **Note**: Using `page` and `hitsPerPage` is the
    /// recommended method for [paging
    /// results](https://www.algolia.com/doc/guides/building-search-ui/ui-and-ux-patterns/pagination/js/). However, you
    /// can use `offset` and `length` to implement [an alternative approach to paging](https://www.algolia.com/doc/guides/building-search-ui/ui-and-ux-patterns/pagination/js/#retrieving-a-subset-of-records-with-offset-and-length).
    public var length: Int?
    /// Search for entries [around a central location](https://www.algolia.com/doc/guides/managing-results/refine-results/geolocation/#filter-around-a-central-point),
    /// enabling a geographical search within a circular area.
    public var aroundLatLng: String?
    /// Search for entries around a location. The location is automatically computed from the requester's IP address.
    public var aroundLatLngViaIP: Bool?
    public var aroundRadius: AroundRadius?
    public var aroundPrecision: AroundPrecision?
    /// Minimum radius (in meters) used for a geographical search when `aroundRadius` isn't set.
    public var minimumAroundRadius: Int?
    /// Search inside a [rectangular area](https://www.algolia.com/doc/guides/managing-results/refine-results/geolocation/#filtering-inside-rectangular-or-polygonal-areas)
    /// (in geographical coordinates).
    public var insideBoundingBox: [[Double]]?
    /// Search inside a [polygon](https://www.algolia.com/doc/guides/managing-results/refine-results/geolocation/#filtering-inside-rectangular-or-polygonal-areas)
    /// (in geographical coordinates).
    public var insidePolygon: [[Double]]?
    /// Changes the default values of parameters that work best for a natural language query, such as `ignorePlurals`,
    /// `removeStopWords`, `removeWordsIfNoResults`, `analyticsTags`, and `ruleContexts`. These parameters work well
    /// together when the query consists of fuller natural language strings instead of keywords, for example when
    /// processing voice search queries.
    public var naturalLanguages: [String]?
    /// Assigns [rule contexts](https://www.algolia.com/doc/guides/managing-results/rules/rules-overview/how-to/customize-search-results-by-platform/#whats-a-context)
    /// to search queries.
    public var ruleContexts: [String]?
    /// Defines how much [Personalization affects results](https://www.algolia.com/doc/guides/personalization/personalizing-results/in-depth/configuring-personalization/#understanding-personalization-impact).
    public var personalizationImpact: Int?
    /// Associates a [user token](https://www.algolia.com/doc/guides/sending-events/concepts/usertoken/) with the
    /// current search.
    public var userToken: String
    /// Incidates whether the search response includes [detailed ranking information](https://www.algolia.com/doc/guides/building-search-ui/going-further/backend-search/in-depth/understanding-the-api-response/#ranking-information).
    public var getRankingInfo: Bool?
    /// Enriches the API's response with information about how the query was processed.
    public var explain: [String]?
    /// Whether to take into account an index's synonyms for a particular search.
    public var synonyms: Bool?
    /// Indicates whether a query ID parameter is included in the search response. This is required for [tracking click
    /// and conversion events](https://www.algolia.com/doc/guides/sending-events/concepts/event-types/#events-related-to-algolia-requests).
    public var clickAnalytics: Bool?
    /// Indicates whether this query will be included in
    /// [analytics](https://www.algolia.com/doc/guides/search-analytics/guides/exclude-queries/).
    public var analytics: Bool?
    /// Tags to apply to the query for [segmenting analytics
    /// data](https://www.algolia.com/doc/guides/search-analytics/guides/segments/).
    public var analyticsTags: [String]?
    /// Whether to include or exclude a query from the processing-time percentile computation.
    public var percentileComputation: Bool?
    /// Incidates whether this search will be considered in A/B testing.
    public var enableABTest: Bool?
    /// Attributes used for [faceting](https://www.algolia.com/doc/guides/managing-results/refine-results/faceting/) and
    /// the [modifiers](https://www.algolia.com/doc/api-reference/api-parameters/attributesForFaceting/#modifiers) that
    /// can be applied: `filterOnly`, `searchable`, and `afterDistinct`.
    public var attributesForFaceting: [String]?
    /// Attributes to include in the API response. To reduce the size of your response, you can retrieve only some of
    /// the attributes. By default, the response includes all attributes.
    public var attributesToRetrieve: [String]?
    /// Determines the order in which Algolia [returns your
    /// results](https://www.algolia.com/doc/guides/managing-results/relevance-overview/in-depth/ranking-criteria/).
    public var ranking: [String]?
    /// Specifies the [Custom ranking
    /// criterion](https://www.algolia.com/doc/guides/managing-results/must-do/custom-ranking/). Use the `asc` and
    /// `desc` modifiers to specify the ranking order: ascending or descending.
    public var customRanking: [String]?
    /// Relevancy threshold below which less relevant results aren't included in the results.
    public var relevancyStrictness: Int?
    /// Attributes to highlight. Strings that match the search query in the attributes are highlighted by surrounding
    /// them with HTML tags (`highlightPreTag` and `highlightPostTag`).
    public var attributesToHighlight: [String]?
    /// Attributes to _snippet_. 'Snippeting' is shortening the attribute to a certain number of words. If not
    /// specified, the attribute is shortened to the 10 words around the matching string but you can specify the number.
    /// For example: `body:20`.
    public var attributesToSnippet: [String]?
    /// HTML string to insert before the highlighted parts in all highlight and snippet results.
    public var highlightPreTag: String?
    /// HTML string to insert after the highlighted parts in all highlight and snippet results.
    public var highlightPostTag: String?
    /// String used as an ellipsis indicator when a snippet is truncated.
    public var snippetEllipsisText: String?
    /// Restrict highlighting and snippeting to items that matched the query.
    public var restrictHighlightAndSnippetArrays: Bool?
    /// Number of hits per page.
    public var hitsPerPage: Int?
    /// Minimum number of characters a word in the query string must contain to accept matches with [one typo](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/typo-tolerance/in-depth/configuring-typo-tolerance/#configuring-word-length-for-typos).
    public var minWordSizefor1Typo: Int?
    /// Minimum number of characters a word in the query string must contain to accept matches with [two typos](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/typo-tolerance/in-depth/configuring-typo-tolerance/#configuring-word-length-for-typos).
    public var minWordSizefor2Typos: Int?
    public var typoTolerance: TypoTolerance?
    /// Whether to allow typos on numbers (\"numeric tokens\") in the query string.
    public var allowTyposOnNumericTokens: Bool?
    /// Attributes for which you want to turn off [typo
    /// tolerance](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/typo-tolerance/).
    public var disableTypoToleranceOnAttributes: [String]?
    public var ignorePlurals: IgnorePlurals?
    public var removeStopWords: RemoveStopWords?
    /// Characters that the engine shouldn't automatically [normalize](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/normalization/).
    public var keepDiacriticsOnCharacters: String?
    /// Sets your user's search language. This adjusts language-specific settings and features such as `ignorePlurals`,
    /// `removeStopWords`, and [CJK](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/normalization/#normalization-for-logogram-based-languages-cjk)
    /// word detection.
    public var queryLanguages: [String]?
    /// [Splits compound words](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/language-specific-configurations/#splitting-compound-words)
    /// into their component word parts in the query.
    public var decompoundQuery: Bool?
    /// Incidates whether [Rules](https://www.algolia.com/doc/guides/managing-results/rules/rules-overview/) are
    /// enabled.
    public var enableRules: Bool?
    /// Incidates whether [Personalization](https://www.algolia.com/doc/guides/personalization/what-is-personalization/)
    /// is enabled.
    public var enablePersonalization: Bool?
    public var queryType: QueryType?
    public var removeWordsIfNoResults: RemoveWordsIfNoResults?
    public var mode: Mode?
    public var semanticSearch: SemanticSearch?
    /// Enables the [advanced query syntax](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/override-search-engine-defaults/#advanced-syntax).
    public var advancedSyntax: Bool?
    /// Words which should be considered [optional](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/empty-or-insufficient-results/#creating-a-list-of-optional-words)
    /// when found in a query.
    public var optionalWords: [String]?
    /// Attributes for which you want to [turn off the exact ranking criterion](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/override-search-engine-defaults/in-depth/adjust-exact-settings/#turn-off-exact-for-some-attributes).
    public var disableExactOnAttributes: [String]?
    public var exactOnSingleWordQuery: ExactOnSingleWordQuery?
    /// Alternatives that should be considered an exact match by [the exact ranking criterion](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/override-search-engine-defaults/in-depth/adjust-exact-settings/#turn-off-exact-for-some-attributes).
    public var alternativesAsExact: [AlternativesAsExact]?
    /// Allows you to specify which advanced syntax features are active when `advancedSyntax` is enabled.
    public var advancedSyntaxFeatures: [AdvancedSyntaxFeatures]?
    public var distinct: Distinct?
    /// Whether to highlight and snippet the original word that matches the synonym or the synonym itself.
    public var replaceSynonymsInHighlight: Bool?
    /// Precision of the [proximity ranking criterion](https://www.algolia.com/doc/guides/managing-results/relevance-overview/in-depth/ranking-criteria/#proximity).
    public var minProximity: Int?
    /// Attributes to include in the API response for search and browse queries.
    public var responseFields: [String]?
    /// Maximum number of facet hits to return when [searching for facet
    /// values](https://www.algolia.com/doc/guides/managing-results/refine-results/faceting/#search-for-facet-values).
    public var maxFacetHits: Int?
    /// Maximum number of facet values to return for each facet.
    public var maxValuesPerFacet: Int?
    /// Controls how facet values are fetched.
    public var sortFacetValuesBy: String?
    /// When the [Attribute criterion is ranked above Proximity](https://www.algolia.com/doc/guides/managing-results/relevance-overview/in-depth/ranking-criteria/#attribute-and-proximity-combinations)
    /// in your ranking formula, Proximity is used to select which searchable attribute is matched in the Attribute
    /// ranking stage.
    public var attributeCriteriaComputedByMinProximity: Bool?
    public var renderingContent: RenderingContent?
    /// Indicates whether this search will use [Dynamic
    /// Re-Ranking](https://www.algolia.com/doc/guides/algolia-ai/re-ranking/).
    public var enableReRanking: Bool?
    public var reRankingApplyFilter: ReRankingApplyFilter?

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.query, forKey: .query)
        try container.encodeIfPresent(self.similarQuery, forKey: .similarQuery)
        try container.encodeIfPresent(self.filters, forKey: .filters)
        try container.encodeIfPresent(self.facetFilters, forKey: .facetFilters)
        try container.encodeIfPresent(self.optionalFilters, forKey: .optionalFilters)
        try container.encodeIfPresent(self.numericFilters, forKey: .numericFilters)
        try container.encodeIfPresent(self.tagFilters, forKey: .tagFilters)
        try container.encodeIfPresent(self.sumOrFiltersScores, forKey: .sumOrFiltersScores)
        try container.encodeIfPresent(self.restrictSearchableAttributes, forKey: .restrictSearchableAttributes)
        try container.encodeIfPresent(self.facets, forKey: .facets)
        try container.encodeIfPresent(self.facetingAfterDistinct, forKey: .facetingAfterDistinct)
        try container.encodeIfPresent(self.page, forKey: .page)
        try container.encodeIfPresent(self.offset, forKey: .offset)
        try container.encodeIfPresent(self.length, forKey: .length)
        try container.encodeIfPresent(self.aroundLatLng, forKey: .aroundLatLng)
        try container.encodeIfPresent(self.aroundLatLngViaIP, forKey: .aroundLatLngViaIP)
        try container.encodeIfPresent(self.aroundRadius, forKey: .aroundRadius)
        try container.encodeIfPresent(self.aroundPrecision, forKey: .aroundPrecision)
        try container.encodeIfPresent(self.minimumAroundRadius, forKey: .minimumAroundRadius)
        try container.encodeIfPresent(self.insideBoundingBox, forKey: .insideBoundingBox)
        try container.encodeIfPresent(self.insidePolygon, forKey: .insidePolygon)
        try container.encodeIfPresent(self.naturalLanguages, forKey: .naturalLanguages)
        try container.encodeIfPresent(self.ruleContexts, forKey: .ruleContexts)
        try container.encodeIfPresent(self.personalizationImpact, forKey: .personalizationImpact)
        try container.encode(self.userToken, forKey: .userToken)
        try container.encodeIfPresent(self.getRankingInfo, forKey: .getRankingInfo)
        try container.encodeIfPresent(self.explain, forKey: .explain)
        try container.encodeIfPresent(self.synonyms, forKey: .synonyms)
        try container.encodeIfPresent(self.clickAnalytics, forKey: .clickAnalytics)
        try container.encodeIfPresent(self.analytics, forKey: .analytics)
        try container.encodeIfPresent(self.analyticsTags, forKey: .analyticsTags)
        try container.encodeIfPresent(self.percentileComputation, forKey: .percentileComputation)
        try container.encodeIfPresent(self.enableABTest, forKey: .enableABTest)
        try container.encodeIfPresent(self.attributesForFaceting, forKey: .attributesForFaceting)
        try container.encodeIfPresent(self.attributesToRetrieve, forKey: .attributesToRetrieve)
        try container.encodeIfPresent(self.ranking, forKey: .ranking)
        try container.encodeIfPresent(self.customRanking, forKey: .customRanking)
        try container.encodeIfPresent(self.relevancyStrictness, forKey: .relevancyStrictness)
        try container.encodeIfPresent(self.attributesToHighlight, forKey: .attributesToHighlight)
        try container.encodeIfPresent(self.attributesToSnippet, forKey: .attributesToSnippet)
        try container.encodeIfPresent(self.highlightPreTag, forKey: .highlightPreTag)
        try container.encodeIfPresent(self.highlightPostTag, forKey: .highlightPostTag)
        try container.encodeIfPresent(self.snippetEllipsisText, forKey: .snippetEllipsisText)
        try container.encodeIfPresent(
            self.restrictHighlightAndSnippetArrays,
            forKey: .restrictHighlightAndSnippetArrays
        )
        try container.encodeIfPresent(self.hitsPerPage, forKey: .hitsPerPage)
        try container.encodeIfPresent(self.minWordSizefor1Typo, forKey: .minWordSizefor1Typo)
        try container.encodeIfPresent(self.minWordSizefor2Typos, forKey: .minWordSizefor2Typos)
        try container.encodeIfPresent(self.typoTolerance, forKey: .typoTolerance)
        try container.encodeIfPresent(self.allowTyposOnNumericTokens, forKey: .allowTyposOnNumericTokens)
        try container.encodeIfPresent(self.disableTypoToleranceOnAttributes, forKey: .disableTypoToleranceOnAttributes)
        try container.encodeIfPresent(self.ignorePlurals, forKey: .ignorePlurals)
        try container.encodeIfPresent(self.removeStopWords, forKey: .removeStopWords)
        try container.encodeIfPresent(self.keepDiacriticsOnCharacters, forKey: .keepDiacriticsOnCharacters)
        try container.encodeIfPresent(self.queryLanguages, forKey: .queryLanguages)
        try container.encodeIfPresent(self.decompoundQuery, forKey: .decompoundQuery)
        try container.encodeIfPresent(self.enableRules, forKey: .enableRules)
        try container.encodeIfPresent(self.enablePersonalization, forKey: .enablePersonalization)
        try container.encodeIfPresent(self.queryType, forKey: .queryType)
        try container.encodeIfPresent(self.removeWordsIfNoResults, forKey: .removeWordsIfNoResults)
        try container.encodeIfPresent(self.mode, forKey: .mode)
        try container.encodeIfPresent(self.semanticSearch, forKey: .semanticSearch)
        try container.encodeIfPresent(self.advancedSyntax, forKey: .advancedSyntax)
        try container.encodeIfPresent(self.optionalWords, forKey: .optionalWords)
        try container.encodeIfPresent(self.disableExactOnAttributes, forKey: .disableExactOnAttributes)
        try container.encodeIfPresent(self.exactOnSingleWordQuery, forKey: .exactOnSingleWordQuery)
        try container.encodeIfPresent(self.alternativesAsExact, forKey: .alternativesAsExact)
        try container.encodeIfPresent(self.advancedSyntaxFeatures, forKey: .advancedSyntaxFeatures)
        try container.encodeIfPresent(self.distinct, forKey: .distinct)
        try container.encodeIfPresent(self.replaceSynonymsInHighlight, forKey: .replaceSynonymsInHighlight)
        try container.encodeIfPresent(self.minProximity, forKey: .minProximity)
        try container.encodeIfPresent(self.responseFields, forKey: .responseFields)
        try container.encodeIfPresent(self.maxFacetHits, forKey: .maxFacetHits)
        try container.encodeIfPresent(self.maxValuesPerFacet, forKey: .maxValuesPerFacet)
        try container.encodeIfPresent(self.sortFacetValuesBy, forKey: .sortFacetValuesBy)
        try container.encodeIfPresent(
            self.attributeCriteriaComputedByMinProximity,
            forKey: .attributeCriteriaComputedByMinProximity
        )
        try container.encodeIfPresent(self.renderingContent, forKey: .renderingContent)
        try container.encodeIfPresent(self.enableReRanking, forKey: .enableReRanking)
        try container.encodeIfPresent(self.reRankingApplyFilter, forKey: .reRankingApplyFilter)
    }

    // MARK: Internal

    static let lengthRule = NumericRule<Int>(
        minimum: 1,
        exclusiveMinimum: false,
        maximum: 1000,
        exclusiveMaximum: false,
        multipleOf: nil
    )
    static let minimumAroundRadiusRule = NumericRule<Int>(
        minimum: 1,
        exclusiveMinimum: false,
        maximum: nil,
        exclusiveMaximum: false,
        multipleOf: nil
    )
    static let hitsPerPageRule = NumericRule<Int>(
        minimum: 1,
        exclusiveMinimum: false,
        maximum: 1000,
        exclusiveMaximum: false,
        multipleOf: nil
    )
    static let minProximityRule = NumericRule<Int>(
        minimum: 1,
        exclusiveMinimum: false,
        maximum: 7,
        exclusiveMaximum: false,
        multipleOf: nil
    )
    static let maxFacetHitsRule = NumericRule<Int>(
        minimum: nil,
        exclusiveMinimum: false,
        maximum: 100,
        exclusiveMaximum: false,
        multipleOf: nil
    )
}
