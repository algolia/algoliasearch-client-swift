//
//  SearchQueryExtension.swift
//  AlgoliaSearchClient
//
//  Created by Algolia on 18/09/2024.
//

public extension SearchQuery {
    init(from searchParamsObject: SearchSearchParamsObject, options: SearchForHitsOptions, params: String? = nil) {
        self = .searchForHits(SearchForHits(from: searchParamsObject, indexName: options.indexName, params: params))
    }

    init(from searchParamsObject: SearchSearchParamsObject, options: SearchForFacetsOptions, params: String? = nil) {
        self = .searchForFacets(SearchForFacets(from: searchParamsObject, options: options, params: params))
    }
}

public extension SearchForHits {
    init(from searchParamsObject: SearchSearchParamsObject, indexName: String, params: String? = nil) {
        self.params = params
        self.query = searchParamsObject.query
        self.similarQuery = searchParamsObject.similarQuery
        self.filters = searchParamsObject.filters
        self.facetFilters = searchParamsObject.facetFilters
        self.optionalFilters = searchParamsObject.optionalFilters
        self.numericFilters = searchParamsObject.numericFilters
        self.tagFilters = searchParamsObject.tagFilters
        self.sumOrFiltersScores = searchParamsObject.sumOrFiltersScores
        self.restrictSearchableAttributes = searchParamsObject.restrictSearchableAttributes
        self.facets = searchParamsObject.facets
        self.facetingAfterDistinct = searchParamsObject.facetingAfterDistinct
        self.page = searchParamsObject.page
        self.offset = searchParamsObject.offset
        self.length = searchParamsObject.length
        self.aroundLatLng = searchParamsObject.aroundLatLng
        self.aroundLatLngViaIP = searchParamsObject.aroundLatLngViaIP
        self.aroundRadius = searchParamsObject.aroundRadius
        self.aroundPrecision = searchParamsObject.aroundPrecision
        self.minimumAroundRadius = searchParamsObject.minimumAroundRadius
        self.insideBoundingBox = searchParamsObject.insideBoundingBox
        self.insidePolygon = searchParamsObject.insidePolygon
        self.naturalLanguages = searchParamsObject.naturalLanguages
        self.ruleContexts = searchParamsObject.ruleContexts
        self.personalizationImpact = searchParamsObject.personalizationImpact
        self.userToken = searchParamsObject.userToken
        self.getRankingInfo = searchParamsObject.getRankingInfo
        self.synonyms = searchParamsObject.synonyms
        self.clickAnalytics = searchParamsObject.clickAnalytics
        self.analytics = searchParamsObject.analytics
        self.analyticsTags = searchParamsObject.analyticsTags
        self.percentileComputation = searchParamsObject.percentileComputation
        self.enableABTest = searchParamsObject.enableABTest
        self.attributesToRetrieve = searchParamsObject.attributesToRetrieve
        self.ranking = searchParamsObject.ranking
        self.relevancyStrictness = searchParamsObject.relevancyStrictness
        self.attributesToHighlight = searchParamsObject.attributesToHighlight
        self.attributesToSnippet = searchParamsObject.attributesToSnippet
        self.highlightPreTag = searchParamsObject.highlightPreTag
        self.highlightPostTag = searchParamsObject.highlightPostTag
        self.snippetEllipsisText = searchParamsObject.snippetEllipsisText
        self.restrictHighlightAndSnippetArrays = searchParamsObject.restrictHighlightAndSnippetArrays
        self.hitsPerPage = searchParamsObject.hitsPerPage
        self.minWordSizefor1Typo = searchParamsObject.minWordSizefor1Typo
        self.minWordSizefor2Typos = searchParamsObject.minWordSizefor2Typos
        self.typoTolerance = searchParamsObject.typoTolerance
        self.allowTyposOnNumericTokens = searchParamsObject.allowTyposOnNumericTokens
        self.disableTypoToleranceOnAttributes = searchParamsObject.disableTypoToleranceOnAttributes
        self.ignorePlurals = searchParamsObject.ignorePlurals
        self.removeStopWords = searchParamsObject.removeStopWords
        self.queryLanguages = searchParamsObject.queryLanguages
        self.decompoundQuery = searchParamsObject.decompoundQuery
        self.enableRules = searchParamsObject.enableRules
        self.enablePersonalization = searchParamsObject.enablePersonalization
        self.queryType = searchParamsObject.queryType
        self.removeWordsIfNoResults = searchParamsObject.removeWordsIfNoResults
        self.mode = searchParamsObject.mode
        self.semanticSearch = searchParamsObject.semanticSearch
        self.advancedSyntax = searchParamsObject.advancedSyntax
        self.optionalWords = searchParamsObject.optionalWords
        self.disableExactOnAttributes = searchParamsObject.disableExactOnAttributes
        self.exactOnSingleWordQuery = searchParamsObject.exactOnSingleWordQuery
        self.alternativesAsExact = searchParamsObject.alternativesAsExact
        self.advancedSyntaxFeatures = searchParamsObject.advancedSyntaxFeatures
        self.distinct = searchParamsObject.distinct
        self.replaceSynonymsInHighlight = searchParamsObject.replaceSynonymsInHighlight
        self.minProximity = searchParamsObject.minProximity
        self.responseFields = searchParamsObject.responseFields
        self.maxValuesPerFacet = searchParamsObject.maxValuesPerFacet
        self.sortFacetValuesBy = searchParamsObject.sortFacetValuesBy
        self.attributeCriteriaComputedByMinProximity = searchParamsObject.attributeCriteriaComputedByMinProximity
        self.renderingContent = searchParamsObject.renderingContent
        self.enableReRanking = searchParamsObject.enableReRanking
        self.reRankingApplyFilter = searchParamsObject.reRankingApplyFilter
        self.indexName = indexName
        self.type = .default
    }

    init(from searchParamsObject: SearchSearchParamsObject, options: SearchForHitsOptions, params: String? = nil) {
        self = .init(from: searchParamsObject, indexName: options.indexName, params: params)
    }
}

public extension SearchForFacets {
    init(from searchParamsObject: SearchSearchParamsObject, options: SearchForFacetsOptions, params: String? = nil) {
        self.params = params
        self.query = searchParamsObject.query
        self.similarQuery = searchParamsObject.similarQuery
        self.filters = searchParamsObject.filters
        self.facetFilters = searchParamsObject.facetFilters
        self.optionalFilters = searchParamsObject.optionalFilters
        self.numericFilters = searchParamsObject.numericFilters
        self.tagFilters = searchParamsObject.tagFilters
        self.sumOrFiltersScores = searchParamsObject.sumOrFiltersScores
        self.restrictSearchableAttributes = searchParamsObject.restrictSearchableAttributes
        self.facets = searchParamsObject.facets
        self.facetingAfterDistinct = searchParamsObject.facetingAfterDistinct
        self.page = searchParamsObject.page
        self.offset = searchParamsObject.offset
        self.length = searchParamsObject.length
        self.aroundLatLng = searchParamsObject.aroundLatLng
        self.aroundLatLngViaIP = searchParamsObject.aroundLatLngViaIP
        self.aroundRadius = searchParamsObject.aroundRadius
        self.aroundPrecision = searchParamsObject.aroundPrecision
        self.minimumAroundRadius = searchParamsObject.minimumAroundRadius
        self.insideBoundingBox = searchParamsObject.insideBoundingBox
        self.insidePolygon = searchParamsObject.insidePolygon
        self.naturalLanguages = searchParamsObject.naturalLanguages
        self.ruleContexts = searchParamsObject.ruleContexts
        self.personalizationImpact = searchParamsObject.personalizationImpact
        self.userToken = searchParamsObject.userToken
        self.getRankingInfo = searchParamsObject.getRankingInfo
        self.synonyms = searchParamsObject.synonyms
        self.clickAnalytics = searchParamsObject.clickAnalytics
        self.analytics = searchParamsObject.analytics
        self.analyticsTags = searchParamsObject.analyticsTags
        self.percentileComputation = searchParamsObject.percentileComputation
        self.enableABTest = searchParamsObject.enableABTest
        self.attributesToRetrieve = searchParamsObject.attributesToRetrieve
        self.ranking = searchParamsObject.ranking
        self.relevancyStrictness = searchParamsObject.relevancyStrictness
        self.attributesToHighlight = searchParamsObject.attributesToHighlight
        self.attributesToSnippet = searchParamsObject.attributesToSnippet
        self.highlightPreTag = searchParamsObject.highlightPreTag
        self.highlightPostTag = searchParamsObject.highlightPostTag
        self.snippetEllipsisText = searchParamsObject.snippetEllipsisText
        self.restrictHighlightAndSnippetArrays = searchParamsObject.restrictHighlightAndSnippetArrays
        self.hitsPerPage = searchParamsObject.hitsPerPage
        self.minWordSizefor1Typo = searchParamsObject.minWordSizefor1Typo
        self.minWordSizefor2Typos = searchParamsObject.minWordSizefor2Typos
        self.typoTolerance = searchParamsObject.typoTolerance
        self.allowTyposOnNumericTokens = searchParamsObject.allowTyposOnNumericTokens
        self.disableTypoToleranceOnAttributes = searchParamsObject.disableTypoToleranceOnAttributes
        self.ignorePlurals = searchParamsObject.ignorePlurals
        self.removeStopWords = searchParamsObject.removeStopWords
        self.queryLanguages = searchParamsObject.queryLanguages
        self.decompoundQuery = searchParamsObject.decompoundQuery
        self.enableRules = searchParamsObject.enableRules
        self.enablePersonalization = searchParamsObject.enablePersonalization
        self.queryType = searchParamsObject.queryType
        self.removeWordsIfNoResults = searchParamsObject.removeWordsIfNoResults
        self.mode = searchParamsObject.mode
        self.semanticSearch = searchParamsObject.semanticSearch
        self.advancedSyntax = searchParamsObject.advancedSyntax
        self.optionalWords = searchParamsObject.optionalWords
        self.disableExactOnAttributes = searchParamsObject.disableExactOnAttributes
        self.exactOnSingleWordQuery = searchParamsObject.exactOnSingleWordQuery
        self.alternativesAsExact = searchParamsObject.alternativesAsExact
        self.advancedSyntaxFeatures = searchParamsObject.advancedSyntaxFeatures
        self.distinct = searchParamsObject.distinct
        self.replaceSynonymsInHighlight = searchParamsObject.replaceSynonymsInHighlight
        self.minProximity = searchParamsObject.minProximity
        self.responseFields = searchParamsObject.responseFields
        self.maxValuesPerFacet = searchParamsObject.maxValuesPerFacet
        self.sortFacetValuesBy = searchParamsObject.sortFacetValuesBy
        self.attributeCriteriaComputedByMinProximity = searchParamsObject.attributeCriteriaComputedByMinProximity
        self.renderingContent = searchParamsObject.renderingContent
        self.enableReRanking = searchParamsObject.enableReRanking
        self.reRankingApplyFilter = searchParamsObject.reRankingApplyFilter
        self.facet = options.facet
        self.indexName = options.indexName
        self.facetQuery = options.facetQuery
        self.maxFacetHits = options.maxFacetHits
        self.type = .facet
    }
}
