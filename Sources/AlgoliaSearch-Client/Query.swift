//
//  Copyright (c) 2015 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation


/// Describes all parameters of a search query.
///
/// There are two ways to access parameters:
///
/// 1. Using the high-level, **typed properties** for individual parameters (recommended).
/// 2. Using the low-level, **untyped accessors** `parameter(withName:)` and `setParameter(withName:to:)` or (better)
///    the **subscript operator**. Use this approach if the parameter you wish to set is not supported by this class.
///
/// + Warning: All parameters are **optional**. When a parameter is `nil`, the API applies a default value.
///
@objc
open class Query : AbstractQuery {
    
    // MARK: -
    
    // MARK: Full text search parameters

    /// The instant-search query string, all words of the query are interpreted as prefixes (for example “John Mc” will
    /// match “John Mccamey” and “Johnathan Mccamey”). If no query parameter is set, retrieves all objects.
    @objc public var query: String? {
        get { return self["query"] }
        set { self["query"] = newValue }
    }
    
    /// Values applicable to the `queryType` parameter.
    public enum QueryType: String {
        /// All query words are interpreted as prefixes.
        case prefixAll = "prefixAll"
        /// Only the last word is interpreted as a prefix (default behavior).
        case prefixLast = "prefixLast"
        /// No query word is interpreted as a prefix. This option is not recommended.
        case prefixNone = "prefixNone"
    }
    /// Selects how the query words are interpreted:
    /// - `prefixAll`: all query words are interpreted as prefixes
    /// - `prefixLast`: only the last word is interpreted as a prefix (default behavior)
    /// - `prefixNone`: no query word is interpreted as a prefix. This option is not recommended.
    public var queryType: QueryType? {
        get {
            guard let value = self["queryType"] else { return nil }
            
            return QueryType(rawValue: value)
        }
        set {
            self["queryType"] = newValue?.rawValue
        }
    }
    
    /// Values applicable to the `typoTolerance` parameter.
    public enum TypoTolerance: String {
        /// Activate typo tolerance entirely.
        case `true` = "true"
        /// De-activate typo tolerance entirely.
        case `false` = "false"
        /// Keep only results with the lowest number of typo. For example if one result match without typos, then
        /// all results with typos will be hidden.
        case min = "min"
        /// If there is a match without typo, then all results with 2 typos or more will be removed. This
        /// option is useful if you want to avoid as much as possible false positive.
        case strict = "strict"
    }
    /// This setting has four different options:
    /// - `true`: activate the typo-tolerance.
    /// - `false`: disable the typo-tolerance.
    /// - `min`: keep only results with the lowest number of typo. For example if one result match without typos, then
    ///   all results with typos will be hidden.
    /// - `strict`: if there is a match without typo, then all results with 2 typos or more will be removed. This
    /// option is useful if you want to avoid as much as possible false positive.
    public var typoTolerance: TypoTolerance? {
        get {
            guard let value = self["typoTolerance"] else { return nil }
            
            return TypoTolerance(rawValue: value)
        }
        set {
            self["typoTolerance"] = newValue?.rawValue
        }
    }

    /// The minimum number of characters in a query word to accept one typo in this word.
    public var minWordSizefor1Typo: UInt? {
        get { return Query.parseUInt(self["minWordSizefor1Typo"]) }
        set { self["minWordSizefor1Typo"] = Query.buildUInt(newValue) }
    }
    
    /// The minimum number of characters in a query word to accept two typos in this word.
    public var minWordSizefor2Typos: UInt? {
        get { return Query.parseUInt(self["minWordSizefor2Typos"]) }
        set { self["minWordSizefor2Typos"] = Query.buildUInt(newValue) }
    }

    /// If set to false, disable typo-tolerance on numeric tokens (=numbers) in the query word. For example the query
    /// "304" will match with "30450", but not with "40450" that would have been the case with typo-tolerance enabled.
    /// Can be very useful on serial numbers and zip codes searches.
    public var allowTyposOnNumericTokens: Bool? {
        get { return Query.parseBool(self["allowTyposOnNumericTokens"]) }
        set { self["allowTyposOnNumericTokens"] = Query.buildBool(newValue) }
    }
    
    /// Applicable values for the `ignorePlurals` parameter.
    public enum IgnorePlurals: Equatable {
        /// Enable/disable plurals on all supported languages.
        case all(Bool)
        /// Enable plurals on a specific set of languages, identified by their ISO code.
        case selected([String])
        
        // NOTE: Associated values disable automatic conformance to `Equatable`, so we have to implement it ourselves.
        static public func ==(lhs: IgnorePlurals, rhs: IgnorePlurals) -> Bool {
            switch (lhs, rhs) {
            case (let .all(lhsValue), let .all(rhsValue)): return lhsValue == rhsValue
            case (let .selected(lhsValue), let .selected(rhsValue)): return lhsValue == rhsValue
            default: return false
            }
        }
    }
    
    /// Consider singular and plurals forms alike to be a match without typo. For example, "car" and "cars", or "foot"
    /// and "feet", will be considered equivalent. This parameter can be:
    ///
    /// You may enable this option for all languages at once (`.all`) or for a specific subset (`.selected`).
    ///
    public var ignorePlurals: IgnorePlurals? {
        get {
            let stringValue = self["ignorePlurals"]
            if let boolValue = Query.parseBool(stringValue) {
                return .all(boolValue)
            } else if let arrayValue = Query.parseStringArray(stringValue) {
                return .selected(arrayValue)
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                switch newValue {
                case let .all(boolValue): self["ignorePlurals"] = Query.buildBool(boolValue)
                case let .selected(arrayValue): self["ignorePlurals"] = Query.buildStringArray(arrayValue)
                }
            } else {
                self["ignorePlurals"] = nil
            }
        }
    }
    
    /// List of attributes you want to use for textual search (must be a subset of the `searchableAttributes` index setting).
    /// Attributes are separated with a comma (for example "name,address" ), you can also use a JSON string array
    /// encoding (for example encodeURIComponent('["name","address"]') ). By default, all attributes specified in
    /// `searchableAttributes` settings are used to search.
    @objc public var restrictSearchableAttributes: [String]? {
        get { return Query.parseStringArray(self["restrictSearchableAttributes"]) }
        set { self["restrictSearchableAttributes"] = Query.buildJSONArray(newValue) }
    }
    
    /// List of contexts for which rules are enabled.
    /// Contextual rules matching any of these contexts are eligible, as well as generic rules.
    /// When empty, only generic rules are eligible.
    @objc public var ruleContexts: [String]? {
        get { return Query.parseStringArray(self["ruleContexts"]) }
        set { self["ruleContexts"] = Query.buildJSONArray(newValue) }
    }
    
    /// If set to false, rules processing is disabled: no rule will match the query. Defaults to true.
    public var enableRules: Bool? {
        get { return Query.parseBool(self["enableRules"]) }
        set { self["enableRules"] = Query.buildBool(newValue) }
    }
    
    /// Enable the advanced query syntax.
    public var advancedSyntax: Bool? {
        get { return Query.parseBool(self["advancedSyntax"]) }
        set { self["advancedSyntax"] = Query.buildBool(newValue) }
    }
    
    /// If set to false, this query will not be taken into account for the Analytics.
    public var analytics: Bool? {
        get { return Query.parseBool(self["analytics"]) }
        set { self["analytics"] = Query.buildBool(newValue) }
    }
    
    /// If set, tag your query with the specified identifiers. Tags can then be used in the Analytics to analyze a
    /// subset of searches only.
    @objc public var analyticsTags: [String]? {
        get { return Query.parseStringArray(self["analyticsTags"]) }
        set { self["analyticsTags"] = Query.buildJSONArray(newValue) }
    }
    
    /// If set to false, this query will not use synonyms defined in configuration.
    public var synonyms: Bool? {
        get { return Query.parseBool(self["synonyms"]) }
        set { self["synonyms"] = Query.buildBool(newValue) }
    }
    
    /// If set to false, words matched via synonyms expansion will not be replaced by the matched synonym in the
    /// highlighted result.
    public var replaceSynonymsInHighlight: Bool? {
        get { return Query.parseBool(self["replaceSynonymsInHighlight"]) }
        set { self["replaceSynonymsInHighlight"] = Query.buildBool(newValue) }
    }
    
    /// Specify a list of words that should be considered as optional when found in the query. This list will be
    /// appended to the one defined in your index settings.
    @objc public var optionalWords: [String]? {
        get { return Query.parseStringArray(self["optionalWords"]) }
        set { self["optionalWords"] = Query.buildJSONArray(newValue) }
    }

    /// Configure the precision of the proximity ranking criterion. By default, the minimum (and best) proximity value
    /// distance between 2 matching words is 1. Setting it to 2 (or 3) would allow 1 (or 2) words to be found between
    /// the matching words without degrading the proximity ranking value.
    ///
    /// Considering the query “javascript framework”, if you set minProximity=2 the records “JavaScript framework” and
    /// “JavaScript charting framework” will get the same proximity score, even if the second one contains a word
    /// between the 2 matching words.
    public var minProximity: UInt? {
        get { return Query.parseUInt(self["minProximity"]) }
        set { self["minProximity"] = Query.buildUInt(newValue) }
    }

    /// Applicable values for the `removeWordsIfNoResults` parameter.
    public enum RemoveWordsIfNoResults: String {
        /// No specific processing is done when a query does not return any result.
        ///
        /// + Warning: Beware of confusion with `Optional.none` when using type inference!
        ///
        case none = "none"
        /// When a query does not return any result, the last word will be added as optionalWords (the
        /// process is repeated with the n-1 word, n-2 word, … until there is results). This option is particularly
        /// useful on e-commerce websites.
        case lastWords = "lastWords"
        /// When a query does not return any result, the first word will be added as optionalWords (the
        /// process is repeated with the second word, third word, … until there is results). This option is useful on
        /// address search.
        case firstWords = "firstWords"
        /// When a query does not return any result, a second trial will be made with all words as
        /// optional (which is equivalent to transforming the AND operand between query terms in a OR operand)
        case allOptional = "allOptional"
    }
    /// Configure the way query words are removed when the query doesn’t retrieve any results. This option can be used
    /// to avoid having an empty result page. There are four different options:
    /// - `lastWords`: when a query does not return any result, the last word will be added as optionalWords (the
    ///   process is repeated with the n-1 word, n-2 word, … until there is results). This option is particularly
    ///   useful on e-commerce websites
    /// - `firstWords`: when a query does not return any result, the first word will be added as optionalWords (the
    ///   process is repeated with the second word, third word, … until there is results). This option is useful on
    ///   address search
    /// - `allOptional`: When a query does not return any result, a second trial will be made with all words as
    ///   optional (which is equivalent to transforming the AND operand between query terms in a OR operand)
    /// - `none`: No specific processing is done when a query does not return any result.
    public var removeWordsIfNoResults: RemoveWordsIfNoResults? {
        get {
            guard let value = self["removeWordsIfNoResults"] else { return nil }
            
            return RemoveWordsIfNoResults(rawValue: value)
        }
        set {
            self["removeWordsIfNoResults"] = newValue?.rawValue
        }
    }
    
    /// List of attributes on which you want to disable typo tolerance (must be a subset of the `searchableAttributes`
    /// index setting).
    @objc public var disableTypoToleranceOnAttributes: [String]? {
        get { return Query.parseStringArray(self["disableTypoToleranceOnAttributes"]) }
        set { self["disableTypoToleranceOnAttributes"] = Query.buildJSONArray(newValue) }
    }
    
    /// Applicable values for the `removeStopWords` parameter.
    public enum RemoveStopWords: Equatable {
        /// Enable/disable stop words on all supported languages.
        case all(Bool)
        /// Enable stop words on a specific set of languages, identified by their ISO code.
        case selected([String])
        
        // NOTE: Associated values disable automatic conformance to `Equatable`, so we have to implement it ourselves.
        static public func ==(lhs: RemoveStopWords, rhs: RemoveStopWords) -> Bool {
            switch (lhs, rhs) {
            case (let .all(lhsValue), let .all(rhsValue)): return lhsValue == rhsValue
            case (let .selected(lhsValue), let .selected(rhsValue)): return lhsValue == rhsValue
            default: return false
            }
        }
    }

    /// Remove stop words from query before executing it.
    /// It can be a boolean: enable or disable all 41 supported languages or a comma separated string with the list of
    /// languages you have in your record (using language iso code). In most use-cases, we don’t recommend enabling
    /// this option.
    ///
    /// Stop words removal is applied on query words that are not interpreted as a prefix. The behavior depends of the
    /// `queryType` parameter:
    ///
    /// - `queryType=prefixLast` means the last query word is a prefix and it won’t be considered for stop words removal
    /// - `queryType=prefixNone` means no query word are prefix, stop words removal will be applied on all query words
    /// - `queryType=prefixAll` means all query terms are prefix, stop words won’t be removed
    ///
    /// This parameter is useful when you have a query in natural language like “what is a record?”. In this case,
    /// before executing the query, we will remove “what”, “is” and “a” in order to just search for “record”. This
    /// removal will remove false positive because of stop words, especially when combined with optional words.
    /// For most use cases, it is better to do not use this feature as people search by keywords on search engines.
    public var removeStopWords: RemoveStopWords? {
        get {
            let stringValue = self["removeStopWords"]
            if let boolValue = Query.parseBool(stringValue) {
                return .all(boolValue)
            } else if let arrayValue = Query.parseStringArray(stringValue) {
                return .selected(arrayValue)
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                switch newValue {
                case let .all(boolValue): self["removeStopWords"] = Query.buildBool(boolValue)
                case let .selected(arrayValue): self["removeStopWords"] = Query.buildStringArray(arrayValue)
                }
            } else {
                self["removeStopWords"] = nil
            }
        }
    }
    
    /// List of attributes on which you want to disable computation of the `exact` ranking criterion
    /// The list must be a subset of the `searchableAttributes` index setting.
    @objc public var disableExactOnAttributes: [String]? {
        get { return Query.parseStringArray(self["disableExactOnAttributes"]) }
        set { self["disableExactOnAttributes"] = Query.buildJSONArray(newValue) }
    }
    
    /// Applicable values for the `exactOnSingleWordQuery` parameter.
    public enum ExactOnSingleWordQuery: String {
        /// No exact on single word query.
        ///
        /// + Warning: Beware of confusion with `Optional.none` when using type inference!
        ///
        case none = "none"
        /// Exact set to 1 if the query word is found in the record. The query word needs to have at least 3 chars and
        /// not be part of our stop words dictionary.
        case word = "word"
        /// (Default) Exact set to 1 if there is an attribute containing a string equals to the query.
        case attribute = "attribute"
    }
    /// This parameter control how the exact ranking criterion is computed when the query contains one word.
    public var exactOnSingleWordQuery: ExactOnSingleWordQuery? {
        get {
            guard let value = self["exactOnSingleWordQuery"] else { return nil }
            
            return ExactOnSingleWordQuery(rawValue: value)
        }
        set {
            self["exactOnSingleWordQuery"] = newValue?.rawValue
        }
    }
    
    /// Applicable values for the `alternativesAsExact` parameter.
    public enum AlternativesAsExact: String {
        /// Alternative word added by the ignore plurals feature.
        case ignorePlurals = "ignorePlurals"
        /// Single word synonym (For example “NY” = “NYC”).
        case singleWordSynonym = "singleWordSynonym"
        /// Synonym over multiple words (For example “NY” = “New York”).
        case multiWordsSynonym = "multiWordsSynonym"
    }
    /// Specify the list of approximation that should be considered as an exact match in the ranking formula.
    ///
    /// - `ignorePlurals`: alternative word added by the ignore plurals feature
    /// - `singleWordSynonym`: single word synonym (For example “NY” = “NYC”)
    /// - `multiWordsSynonym`: synonym over multiple words (For example “NY” = “New York”)
    ///
    /// The default value is `ignorePlurals,singleWordSynonym`.
    ///
    public var alternativesAsExact: [AlternativesAsExact]? {
        get {
            guard let rawValues = Query.parseStringArray(self["alternativesAsExact"]) else {
                return nil
            }
            var values = [AlternativesAsExact]()
            for rawValue in rawValues {
                if let value = AlternativesAsExact(rawValue: rawValue) {
                    values.append(value)
                }
            }
            return values
        }
        set {
            var rawValues: [String]?
            if newValue != nil {
                rawValues = []
                for value in newValue! {
                    rawValues?.append(value.rawValue)
                }
            }
            self["alternativesAsExact"] = Query.buildStringArray(rawValues)
        }
    }
    
    // MARK: Pagination parameters
    
    /// Pagination parameter used to select the page to retrieve. Page is zero-based and defaults to 0. Thus, to
    /// retrieve the 10th page you need to set `page=9`
    public var page: UInt? {
        get { return Query.parseUInt(self["page"]) }
        set { self["page"] = Query.buildUInt(newValue) }
    }
    
    /// Pagination parameter used to select the number of hits per page. Defaults to 20.
    public var hitsPerPage: UInt? {
        get { return Query.parseUInt(self["hitsPerPage"]) }
        set { self["hitsPerPage"] = Query.buildUInt(newValue) }
    }
    
    /// Offset of the first hit to return (zero-based).
    ///
    /// + Note: In most cases, page/hitsPerPage is the recommended method for pagination.
    public var offset: UInt? {
        get { return Query.parseUInt(self["offset"]) }
        set { self["offset"] = Query.buildUInt(newValue) }
    }
    
    /// Maximum number of hits to return. (1000 is the maximum)
    ///
    /// +Note: In most cases, page/hitsPerPage is the recommended method for pagination.
    public var length: UInt? {
        get { return Query.parseUInt(self["length"]) }
        set { self["length"] = Query.buildUInt(newValue) }
    }
    
    // MARK: Parameters to control results content
    
    /// List of object attributes you want to retrieve (let you minimize the answer size). You can also use `*` to
    /// retrieve all values when an `attributesToRetrieve` setting is specified for your index.
    /// By default all attributes are retrieved.
    @objc public var attributesToRetrieve: [String]? {
        get { return Query.parseStringArray(self["attributesToRetrieve"]) }
        set { self["attributesToRetrieve"] = Query.buildJSONArray(newValue) }
    }
    
    /// List of attributes you want to highlight according to the query. If an attribute has no match for the query,
    /// the raw value is returned. By default all indexed text attributes are highlighted. You can use `*` if you want
    /// to highlight all textual attributes. Numerical attributes are not highlighted. A `matchLevel` is returned for
    /// each highlighted attribute and can contain:
    /// - `full`: if all the query terms were found in the attribute
    /// - `partial`: if only some of the query terms were found
    /// - `none`: if none of the query terms were found
    @objc public var attributesToHighlight: [String]? {
        get { return Query.parseStringArray(self["attributesToHighlight"]) }
        set { self["attributesToHighlight"] = Query.buildJSONArray(newValue) }
    }
    
    /// List of attributes to snippet alongside the number of words to return (syntax is `attributeName:nbWords`).
    /// By default no snippet is computed.
    @objc public var attributesToSnippet: [String]? {
        get { return Query.parseStringArray(self["attributesToSnippet"]) }
        set { self["attributesToSnippet"] = Query.buildJSONArray(newValue) }
    }
    
    /// If set to true, the result hits will contain ranking information in `_rankingInfo` attribute.
    public var getRankingInfo: Bool? {
        get { return Query.parseBool(self["getRankingInfo"]) }
        set { self["getRankingInfo"] = Query.buildBool(newValue) }
    }
    
    /// Specify the string that is inserted before the highlighted parts in the query result (defaults to `<em>`).
    @objc public var highlightPreTag: String? {
        get { return self["highlightPreTag"] }
        set { self["highlightPreTag"] = newValue }
    }
    
    /// Specify the string that is inserted after the highlighted parts in the query result (defaults to `</em>`)
    @objc public var highlightPostTag: String? {
        get { return self["highlightPostTag"] }
        set { self["highlightPostTag"] = newValue }
    }
    
    /// String used as an ellipsis indicator when a snippet is truncated (defaults to empty).
    @objc public var snippetEllipsisText : String? {
        get { return self["snippetEllipsisText"] }
        set { self["snippetEllipsisText"] = newValue }
    }
    
    /// Restrict arrays in highlight and snippet results to items that matched the query. (defaults to `false`).
    /// When `false`, all array items are highlighted/snippeted. When `true`, only array items that matched at least partially are highlighted/snippeted.
    public var restrictHighlightAndSnippetArrays: Bool? {
        get { return Query.parseBool(self["restrictHighlightAndSnippetArrays"]) }
        set { self["restrictHighlightAndSnippetArrays"] = Query.buildBool(newValue) }
    }
    
    // MARK: Numeric search parameters

    /// Filter on numeric attributes.
    @objc public var numericFilters: [Any]? {
        get { return Query.parseJSONArray(self["numericFilters"]) }
        set { self["numericFilters"] = Query.buildJSONArray(newValue) }
    }
    
    // MARK: Category search parameters

    /// Filter the query by a set of tags.
    @objc public var tagFilters: [Any]? {
        get { return Query.parseJSONArray(self["tagFilters"]) }
        set { self["tagFilters"] = Query.buildJSONArray(newValue) }
    }
    
    // MARK: Distinct parameter

    /// Enable the distinct feature (disabled by default) if the attributeForDistinct index setting is set. This
    /// feature is similar to the SQL “distinct” keyword: when enabled in a query with the `distinct=1` parameter,
    /// all hits containing a duplicate value for the `attributeForDistinct` attribute are removed from results.
    /// For example, if the chosen attribute is `_showname` and several hits have the same value for `_showname`, then
    /// only the best one is kept and others are removed.
    public var distinct: UInt? {
        get { return Query.parseUInt(self["distinct"]) }
        set { self["distinct"] = Query.buildUInt(newValue) }
    }
    
    // MARK: Faceting parameters
    
    /// List of object attributes that you want to use for faceting. Only attributes that have been added in
    /// `attributesForFaceting` index setting can be used in this parameter. You can also use `*` to perform faceting
    /// on all attributes specified in `attributesForFaceting`. If the number of results is important, the count can
    /// be approximate, the attribute `exhaustiveFacetsCount` in the response is true when the count is exact.
    @objc public var facets: [String]? {
        get { return Query.parseStringArray(self["facets"]) }
        set { self["facets"] = Query.buildJSONArray(newValue) }
    }
    
    /// Filter the query by a list of facets.
    @objc public var facetFilters: [Any]? {
        get { return Query.parseJSONArray(self["facetFilters"]) }
        set { self["facetFilters"] = Query.buildJSONArray(newValue) }
    }
    
    /// Limit the number of facet values returned for each facet. For example: `maxValuesPerFacet=10` will retrieve
    /// max 10 values per facet.
    public var maxValuesPerFacet: UInt? {
        get { return Query.parseUInt(self["maxValuesPerFacet"]) }
        set { self["maxValuesPerFacet"] = Query.buildUInt(newValue) }
    }
    
    /// Force faceting to be applied after de-duplication.
    ///
    /// + Warning: There are strong requirements and caveats to this feature (including a performance impact),
    ///   so please refer to the online documentation before enabling it.
    ///
    public var facetingAfterDistinct: Bool? {
        get { return Query.parseBool(self["facetingAfterDistinct"]) }
        set { self["facetingAfterDistinct"] = Query.buildBool(newValue) }
    }

    // MARK: Unified filter parameter (SQL like)

    /// Filter the query with numeric, facet or/and tag filters.
    /// The syntax is a SQL like syntax, you can use the OR and AND keywords. The syntax for the underlying numeric,
    /// facet and tag filters is the same than in the other filters:
    ///
    ///     available=1 AND (category:Book OR NOT category:Ebook) AND _publicationdate: 1441745506 TO 1441755506
    ///     AND inStock > 0 AND author:"John Doe"
    ///
    /// The list of keywords is:
    ///
    /// - `OR`: create a disjunctive filter between two filters.
    /// - `AND`: create a conjunctive filter between two filters.
    /// - `TO`: used to specify a range for a numeric filter.
    /// - `NOT`: used to negate a filter. The syntax with the `-` isn't allowed.
    ///
    @objc public var filters: String? {
        get { return self["filters"] }
        set { self["filters"] = newValue }
    }

    // MARK: Geo-search parameters
    
    /// Search for entries around a given latitude/longitude. You can specify the maximum distance in meters with the
    /// `aroundRadius` parameter but we recommend to let it unset and let our automatic radius computation adapt it
    /// depending of the density of the are. At indexing, you should specify the geo-location of an object with the
    /// `_geoloc` attribute (in the form `"_geoloc":{"lat":48.853409, "lng":2.348800}` or
    /// `"_geoloc":[{"lat":48.853409, "lng":2.348800},{"lat":48.547456, "lng":2.972075}]` if you have several
    /// geo-locations in your record).
    @objc public var aroundLatLng: LatLng? {
        get {
            if let fields = self["aroundLatLng"]?.components(separatedBy: ",") {
                if fields.count == 2 {
                    if let lat = Double(fields[0]), let lng = Double(fields[1]) {
                        return LatLng(lat: lat, lng: lng)
                    }
                }
            }
            return nil
        }
        set {
            self["aroundLatLng"] = newValue == nil ? nil : "\(newValue!.lat),\(newValue!.lng)"
        }
    }

    /// Same than aroundLatLng but using IP geolocation instead of manually specified latitude/longitude.
    public var aroundLatLngViaIP: Bool? {
        get { return Query.parseBool(self["aroundLatLngViaIP"]) }
        set { self["aroundLatLngViaIP"] = Query.buildBool(newValue) }
    }
    
    /// Applicable values for the `aroundRadius` parameter.
    public enum AroundRadius: Equatable {
        /// Specify an explicit value (in meters).
        case explicit(UInt)
        
        /// Compute the geo distance without filtering in a geo area.
        /// This option will be faster than specifying a big integer.
        case all

        // NOTE: Associated values disable automatic conformance to `Equatable`, so we have to implement it ourselves.
        static public func ==(lhs: AroundRadius, rhs: AroundRadius) -> Bool {
            switch (lhs, rhs) {
            case (let .explicit(lhsValue), let .explicit(rhsValue)): return lhsValue == rhsValue
            case (.all, .all): return true
            default: return false
            }
        }
    }
    
    /// Control the radius associated with a `aroundLatLng` or `aroundLatLngViaIP` query.
    /// If not set, the radius is computed automatically using the density of the area. You can retrieve the computed
    /// radius in the `automaticRadius` attribute of the answer. You can also specify a minimum value for the automatic
    /// radius by using the `minimumAroundRadius` query parameter. You can specify `.all` if you want to
    /// compute the geo distance without filtering in a geo area (this option will be faster than specifying a big
    /// integer).
    ///
    public var aroundRadius: AroundRadius? {
        get {
            if let stringValue = self["aroundRadius"] {
                if stringValue == "all" {
                    return .all
                } else if let value = Query.parseUInt(stringValue) {
                    return .explicit(value)
                }
            }
            return nil
        }
        set {
            if let newValue = newValue {
                switch newValue {
                case let .explicit(value): self["aroundRadius"] = Query.buildUInt(value)
                case .all: self["aroundRadius"] = "all"
                }
            } else {
                self["aroundRadius"] = nil
            }
        }
    }

    /// Control the precision of a `aroundLatLng` query. In meter. For example if you set `aroundPrecision=100`, two
    /// objects that are in the range 0-99m will be considered as identical in the ranking for the .variable geo
    /// ranking parameter (same for 100-199, 200-299, … ranges).
    public var aroundPrecision: UInt? {
        get { return Query.parseUInt(self["aroundPrecision"]) }
        set { self["aroundPrecision"] = Query.buildUInt(newValue) }
    }

    /// Define the minimum radius used for `aroundLatLng` or `aroundLatLngViaIP` when `aroundRadius` is not set. The
    /// radius is computed automatically using the density of the area. You can retrieve the computed radius in the
    /// `automaticRadius` attribute of the answer.
    public var minimumAroundRadius: UInt? {
        get { return Query.parseUInt(self["minimumAroundRadius"]) }
        set { self["minimumAroundRadius"] = Query.buildUInt(newValue) }
    }
    
    /// Search for entries inside a given area defined by the two extreme points of a rectangle.
    /// You can use several bounding boxes (OR) by passing more than 1 value.
    @objc public var insideBoundingBox: [GeoRect]? {
        get {
            if let fields = self["insideBoundingBox"]?.components(separatedBy: ",") {
                if fields.count % 4 == 0 {
                    var result = [GeoRect]()
                    for i in 0..<(fields.count / 4) {
                        if let lat1 = Double(fields[4 * i + 0]), let lng1 = Double(fields[4 * i + 1]), let lat2 = Double(fields[4 * i + 2]), let lng2 = Double(fields[4 * i + 3]) {
                            result.append(GeoRect(p1: LatLng(lat: lat1, lng: lng1), p2: LatLng(lat: lat2, lng: lng2)))
                        }
                    }
                    return result
                }
            }
            return nil
        }
        set {
            if let dstPolygons = newValue {
                let components = dstPolygons.flatMap({ dstPolygon -> [String] in
                    let p1Lat = String(dstPolygon.p1.lat)
                    let p1Lng = String(dstPolygon.p1.lng)
                    let p2Lat = String(dstPolygon.p2.lat)
                    let p2Lng = String(dstPolygon.p2.lng)
                    
                    return [p1Lat, p1Lng, p2Lat, p2Lng]
                })
                self["insideBoundingBox"] = components.joined(separator: ",")
            } else {
              self["insideBoundingBox"] = nil
            }
        }
    }

    /// Search entries inside a given area defined by a union of polygons.
    /// Each polygon must be defined by a minimum of 3 points.
    @objc public var insidePolygon: [[LatLng]]? {
        get {
            if let data = self["insidePolygon"]?.data(using: .utf8, allowLossyConversion: false),
               let srcPolygons = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[Double]] {
                var dstPolygons = [[LatLng]]()
                for srcPolygon in srcPolygons {
                    var dstPolygon = [LatLng]()
                    if srcPolygon.count % 2 != 0 { continue }
                    for i in 0 ..< srcPolygon.count / 2 {
                        let point = LatLng(lat: srcPolygon[2 * i], lng: srcPolygon[2 * i + 1])
                        dstPolygon.append(point)
                    }
                    dstPolygons.append(dstPolygon)
                }
                return dstPolygons
            }
            return nil
        }
        set {
            if let srcPolygons = newValue {
                let components = srcPolygons.map({
                  "[" + $0.map({ latLng in
                    let lat = String(latLng.lat)
                    let lng = String(latLng.lng)
                    return "\(lat),\(lng)"}).joined(separator: ",") + "]"
                })
                self["insidePolygon"] = "[" + components.joined(separator: ",") + "]"
            } else {
                self["insidePolygon"] = nil
            }
        }
    }
    
    /// Values applicable to the `sortFacetValuesBy` parameter.
    public enum SortFacetValuesBy: String {
        /// Facet values are sorted by decreasing count, the count being the number of records containing this facet value in the results of the query (default behavior).
        case count = "count"
        /// Facet values are sorted by increasing alphabetical order.
        case alpha = "alpha"
    }
    
    /// Controls how the facet values are sorted within each faceted attribute.
    public var sortFacetValuesBy: SortFacetValuesBy? {
        get {
            guard let value = self["sortFacetValuesBy"] else { return nil }
            
            return SortFacetValuesBy(rawValue: value)
        }
        set {
            self["sortFacetValuesBy"] = newValue?.rawValue
        }
    }
    
    // MARK: Advanced
    
    /// Choose which fields the response will contain. Applies to search and browse queries.
    ///
    /// By default, all fields are returned. If this parameter is specified, only the fields explicitly listed will be
    /// returned, unless `*` is used, in which case all fields are returned. Specifying an empty list or unknown field
    /// names is an error.
    ///
    /// This parameter is mainly intended to limit the response size. For example, for complex queries, echoing of
    /// request parameters in the response's params field can be undesirable.
    ///
    /// Some fields cannot be filtered out:
    ///
    /// - `warning` message
    /// - `cursor` in browse queries
    /// - fields triggered explicitly via `getRankingInfo`
    ///
    @objc public var responseFields: [String]? {
        get { return Query.parseStringArray(self["responseFields"]) }
        set { self["responseFields"] = Query.buildJSONArray(newValue) }
    }

    /// Maximum number of facet hits to return during a search for facet values.
    ///
    /// + Note: Does not apply to regular search queries.
    ///
    /// + Note: For performance reasons, the maximum allowed number of returned values is 100.
    ///   Any value outside the range [1, 100] will be rejected.
    ///
    /// + SeeAlso: `Index.searchForFacetValues(...)`
    ///
    public var maxFacetHits: UInt? {
        get { return Query.parseUInt(self["maxFacetHits"]) }
        set { self["maxFacetHits"] = Query.buildUInt(newValue) }
    }

    /// Whether to include the query in processing time percentile computation.
    ///
    /// When true, the API records the processing time of the search query and includes it when computing the 90% and
    /// 99% percentiles, available in your Algolia dashboard. When `false`, the search query is excluded from
    /// percentile computation.
    ///
    public var percentileComputation: Bool? {
        get { return Query.parseBool(self["percentileComputation"]) }
        set { self["percentileComputation"] = Query.buildBool(newValue) }
    }
    
    // MARK: - Initialization

    /// Construct a query with the specified full text query.
    @objc public convenience init(query: String?) {
        self.init()
        self.query = query
    }
    
    /// Clone an existing query.
    @objc public convenience init(copy: Query) {
        self.init(parameters: copy.parameters)
    }

    // MARK: NSCopying

    /// Support for `NSCopying`.
    ///
    /// + Note: Primarily intended for Objective-C use. Swift coders should use `init(copy:)`.
    ///
    @objc open override func copy(with zone: NSZone?) -> Any {
        // NOTE: As per the docs, the zone argument is ignored.
        return Query(copy: self)
    }

    // MARK: Serialization & parsing

    /// Parse a query from a URL query string.
    @objc
    public static func parse(_ queryString: String) -> Query {
        let query = Query()
        parse(queryString, into: query)
        return query
    }

    // MARK: - Objective-C bridges
    // ---------------------------
    // NOTE: Should not be used from Swift.
    // WARNING: Should not be documented.
    
    @objc(queryType)
    public var z_objc_queryType: String? {
        get { return queryType?.rawValue }
        set { queryType = newValue == nil ? nil : QueryType(rawValue: newValue!) }
    }

    @objc(typoTolerance)
    public var z_objc_typoTolerance: String? {
        get { return typoTolerance?.rawValue }
        set { typoTolerance = newValue == nil ? nil : TypoTolerance(rawValue: newValue!) }
    }

    @objc(minWordSizefor1Typo)
    public var z_objc_minWordSizefor1Typo: NSNumber? {
        get { return AbstractQuery.toNumber(self.minWordSizefor1Typo) }
        set { self.minWordSizefor1Typo = newValue?.uintValue }
    }
    
    @objc(minWordSizefor2Typos)
    public var z_objc_minWordSizefor2Typos: NSNumber? {
        get { return AbstractQuery.toNumber(self.minWordSizefor2Typos) }
        set { self.minWordSizefor2Typos = newValue?.uintValue }
    }
    
    @objc(allowTyposOnNumericTokens)
    public var z_objc_allowTyposOnNumericTokens: NSNumber? {
        get { return AbstractQuery.toNumber(self.allowTyposOnNumericTokens) }
        set { self.allowTyposOnNumericTokens = newValue?.boolValue }
    }

    @objc(ignorePlurals)
    public var z_objc_ignorePlurals: Any? {
        get {
            if let value = ignorePlurals {
                switch value {
                case let .all(boolValue): return NSNumber(value: boolValue)
                case let .selected(arrayValue): return arrayValue
                }
            } else {
                return nil
            }
        }
        set {
            if let boolValue = newValue as? Bool {
                ignorePlurals = .all(boolValue)
            } else if let numberValue = newValue as? NSNumber {
                ignorePlurals = .all(numberValue.boolValue)
            } else if let arrayValue = newValue as? [String] {
                ignorePlurals = .selected(arrayValue)
            } else {
                ignorePlurals = nil
            }
        }
    }

    @objc(enableRules)
    public var z_objc_enableRules: NSNumber? {
        get { return AbstractQuery.toNumber(self.enableRules) }
        set { self.enableRules = newValue?.boolValue }
    }
    
    @objc(advancedSyntax)
    public var z_objc_advancedSyntax: NSNumber? {
        get { return AbstractQuery.toNumber(self.advancedSyntax) }
        set { self.advancedSyntax = newValue?.boolValue }
    }

    @objc(analytics)
    public var z_objc_analytics: NSNumber? {
        get { return AbstractQuery.toNumber(self.analytics) }
        set { self.analytics = newValue?.boolValue }
    }

    @objc(synonyms)
    public var z_objc_synonyms: NSNumber? {
        get { return AbstractQuery.toNumber(self.synonyms) }
        set { self.synonyms = newValue?.boolValue }
    }

    @objc(replaceSynonymsInHighlight)
    public var z_objc_replaceSynonymsInHighlight: NSNumber? {
        get { return AbstractQuery.toNumber(self.replaceSynonymsInHighlight) }
        set { self.replaceSynonymsInHighlight = newValue?.boolValue }
    }

    @objc(minProximity)
    public var z_objc_minProximity: NSNumber? {
        get { return AbstractQuery.toNumber(self.minProximity) }
        set { self.minProximity = newValue?.uintValue }
    }

    @objc(removeWordsIfNoResults)
    public var z_objc_removeWordsIfNoResults: String? {
        get { return removeWordsIfNoResults?.rawValue }
        set { removeWordsIfNoResults = newValue == nil ? nil : RemoveWordsIfNoResults(rawValue: newValue!) }
    }

    @objc(removeStopWords)
    public var z_objc_removeStopWords: Any? {
        get {
            if let value = removeStopWords {
                switch value {
                case let .all(boolValue): return NSNumber(value: boolValue)
                case let .selected(arrayValue): return arrayValue
                }
            } else {
                return nil
            }
        }
        set {
            if let boolValue = newValue as? Bool {
                removeStopWords = .all(boolValue)
            } else if let numberValue = newValue as? NSNumber {
                removeStopWords = .all(numberValue.boolValue)
            } else if let arrayValue = newValue as? [String] {
                removeStopWords = .selected(arrayValue)
            } else {
                removeStopWords = nil
            }
        }
    }

    @objc(exactOnSingleWordQuery)
    public var z_objc_exactOnSingleWordQuery: String? {
        get { return exactOnSingleWordQuery?.rawValue }
        set { exactOnSingleWordQuery = newValue == nil ? nil : ExactOnSingleWordQuery(rawValue: newValue!) }
    }

    @objc(alternativesAsExact)
    public var z_objc_alternativesAsExact: [String]? {
        get {
            if let alternativesAsExact = alternativesAsExact {
                return alternativesAsExact.map({ $0.rawValue })
            } else {
                return nil
            }
        }
        set(stringValues) {
            if let stringValues = stringValues {
                var newValues = [AlternativesAsExact]()
                for stringValue in stringValues {
                    if let newValue = AlternativesAsExact(rawValue: stringValue) {
                        newValues.append(newValue)
                    }
                }
                alternativesAsExact = newValues
            } else {
                alternativesAsExact = nil
            }
        }
    }

    @objc(page)
    public var z_objc_page: NSNumber? {
        get { return AbstractQuery.toNumber(self.page) }
        set { self.page = newValue?.uintValue }
    }

    @objc(hitsPerPage)
    public var z_objc_hitsPerPage: NSNumber? {
        get { return AbstractQuery.toNumber(self.hitsPerPage) }
        set { self.hitsPerPage = newValue?.uintValue }
    }
    
    @objc(offset)
    public var z_objc_offset: NSNumber? {
        get { return AbstractQuery.toNumber(self.offset) }
        set { self.offset = newValue?.uintValue }
    }
    
    @objc(length)
    public var z_objc_length: NSNumber? {
        get { return AbstractQuery.toNumber(self.length) }
        set { self.length = newValue?.uintValue }
    }

    @objc(getRankingInfo)
    public var z_objc_getRankingInfo: NSNumber? {
        get { return AbstractQuery.toNumber(self.getRankingInfo) }
        set { self.getRankingInfo = newValue?.boolValue }
    }
    
    @objc(restrictHighlightAndSnippetArrays)
    public var z_objc_restrictHighlightAndSnippetArrays: NSNumber? {
        get { return AbstractQuery.toNumber(self.restrictHighlightAndSnippetArrays) }
        set { self.restrictHighlightAndSnippetArrays = newValue?.boolValue }
    }

    @objc(distinct)
    public var z_objc_distinct: NSNumber? {
        get { return AbstractQuery.toNumber(self.distinct) }
        set { self.distinct = newValue?.uintValue }
    }

    @objc(maxValuesPerFacet)
    public var z_objc_maxValuesPerFacet: NSNumber? {
        get { return AbstractQuery.toNumber(self.maxValuesPerFacet) }
        set { self.maxValuesPerFacet = newValue?.uintValue }
    }

    @objc(aroundLatLngViaIP)
    public var z_objc_aroundLatLngViaIP: NSNumber? {
        get { return AbstractQuery.toNumber(self.aroundLatLngViaIP) }
        set { self.aroundLatLngViaIP = newValue?.boolValue }
    }

    // Special value for `aroundRadius` to compute the geo distance without filtering.
    @objc(aroundRadiusAll) public static let z_objc_aroundRadiusAll: NSNumber = NSNumber(value: UInt.max)

    @objc(aroundRadius)
    public var z_objc_aroundRadius: NSNumber? {
        get {
            if let aroundRadius = aroundRadius {
                switch aroundRadius {
                case let .explicit(value): return NSNumber(value: value)
                case .all: return Query.z_objc_aroundRadiusAll
                }
            }
            return nil
        }
        set {
            if let newValue = newValue {
                if newValue == Query.z_objc_aroundRadiusAll {
                    self.aroundRadius = .all
                } else {
                    self.aroundRadius = .explicit(newValue.uintValue)
                }
            } else {
                self.aroundRadius = nil
            }
        }
    }

    @objc(aroundPrecision)
    public var z_objc_aroundPrecision: NSNumber? {
        get { return AbstractQuery.toNumber(self.aroundPrecision) }
        set { self.aroundPrecision = newValue?.uintValue }
    }

    @objc(minimumAroundRadius)
    public var z_objc_minimumAroundRadius: NSNumber? {
        get { return AbstractQuery.toNumber(self.minimumAroundRadius) }
        set { self.minimumAroundRadius = newValue?.uintValue }
    }
    
    @objc(facetingAfterDistinct)
    public var z_objc_facetingAfterDistinct: NSNumber? {
        get { return AbstractQuery.toNumber(self.facetingAfterDistinct) }
        set { self.facetingAfterDistinct = newValue?.boolValue }
    }

    @objc(maxFacetHits)
    public var z_objc_maxFacetHits: NSNumber? {
        get { return AbstractQuery.toNumber(self.maxFacetHits) }
        set { self.maxFacetHits = newValue?.uintValue }
    }

    @objc(percentileComputation)
    public var z_objc_percentileComputation: NSNumber? {
        get { return AbstractQuery.toNumber(self.percentileComputation) }
        set { self.percentileComputation = newValue?.boolValue }
    }
    
    @objc(sortFacetValuesBy)
    public var z_objc_sortFacetValuesBy: String? {
        get { return sortFacetValuesBy?.rawValue }
        set { sortFacetValuesBy = newValue == nil ? nil : SortFacetValuesBy(rawValue: newValue!) }
    }
}
