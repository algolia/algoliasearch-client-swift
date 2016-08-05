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


// ----------------------------------------------------------------------------
// IMPLEMENTATION NOTES
// ----------------------------------------------------------------------------
// # Typed vs untyped parameters
//
// All parameters are stored as untyped, string values. They can be
// accessed via the low-level `get` and `set` methods (or the subscript
// operator).
//
// Besides, the class provides typed properties, acting as wrappers on top
// of the untyped storage (i.e. serializing to and parsing from string
// values).
//
// # Bridgeability
//
// **This Swift client must be bridgeable to Objective-C.**
//
// Unfortunately, query parameters with primitive types (Int, Bool...) are not
// bridgeable, because all parameters are optional, and primitive optionals are
// not bridgeable to Objective-C.
//
// Consequently, for those parameters, the type is `NSNumber`, which properly
// allows to represent an optional integral type in Objective-C. Because Swift
// automatically bridges integral types to (but not from) `NSNumber`, the
// parameters can still be set using Swift's integral types (`Int`, `Bool`).
// Getting them, however, will result in an `NSNumber` instance, which has to
// be explicitly cast to the adequate type.
//
// For type-checking purposes, `NSNumber`-typed properties have a more strongly
// typed variant (named with a trailing underscore), which allows to further
// restrict the value passed via `NSNumber`. This property is only internally
// accessible (to avoid confusion)... except in the case of enums (see below).
//
// ## The case of enums
//
// Enums can only be bridged to Objective-C if their raw type is integral.
// We could do that, but since parameters are optional and optional value types
// cannot be bridged anyway (see above), this would be pointless: the type
// safety of the enum would be lost in the wrapping into `NSNumber`. Therefore,
// enums have a string raw value, and the Objective-C bridge uses a plain
// `NSString`.
//
// Because this is sub-optimal in Swift, as an exception, the trailing
// underscore-named property for those parameters is publicly exposed. This
// allows Swift users to leverage the full type safety of enums (at the price
// of a little confusion).
//
// ## The case of structs
//
// Auxiliary types used for query parameters, like `LatLng` or `GeoRect`, have
// value semantics. However, structs are not bridgeable to Objective-C. Therefore
// we use plain classes (inheriting from `NSObject`) and we make them immutable.
//
// Equality comparison is implemented in those classes only for the sake of
// testability (we use comparisons extensively in unit tests).
//
// ## Annotations
//
// Properties and methods visible in Objective-C are annotated with `@objc`.
// From an implementation point of view, this is not necessary, because `Query`
// derives from `NSObject` and thus every brdigeable property/method is
// automatically bridged. We use these annotations as hints for maintainers
// (so please keep them).
//
// ----------------------------------------------------------------------------


/// A pair of (latitude, longitude).
/// Used in geo-search.
///
@objc public class LatLng: NSObject {
    // IMPLEMENTATION NOTE: Cannot be `struct` because of Objective-C bridgeability.
    
    /// Latitude.
    public let lat: Double
    
    /// Longitude.
    public let lng: Double
    
    /// Create a geo location.
    ///
    /// - parameter lat: Latitude.
    /// - parameter lng: Longitude.
    ///
    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? LatLng {
            return self.lat == rhs.lat && self.lng == rhs.lng
        } else {
            return false
        }
    }
}

public func ==(lhs: LatLng, rhs: LatLng) -> Bool {
    return lhs.lat == rhs.lat && lhs.lng == rhs.lng
}


/// A rectangle in geo coordinates.
/// Used in geo-search.
///
@objc public class GeoRect: NSObject {
    // IMPLEMENTATION NOTE: Cannot be `struct` because of Objective-C bridgeability.
    
    /// One of the rectangle's corners (typically the northwesternmost).
    public let p1: LatLng
    
    /// Corner opposite from `p1` (typically the southeasternmost).
    public let p2: LatLng
    
    /// Create a geo rectangle.
    ///
    /// - parameter p1: One of the rectangle's corners (typically the northwesternmost).
    /// - parameter p2: Corner opposite from `p1` (typically the southeasternmost).
    ///
    public init(p1: LatLng, p2: LatLng) {
        self.p1 = p1
        self.p2 = p2
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? GeoRect {
            return self.p1 == rhs.p1 && self.p2 == rhs.p2
        } else {
            return false
        }
    }
}


/// Describes all parameters of a search query.
///
/// There are two ways to access parameters:
///
/// 1. Using the high-level, **typed properties** for individual parameters (recommended).
/// 2. Using the low-level, **untyped accessors** `get(_:)` and `set(_:value:)` or the subscript operator.
///    Use this approach if the parameter you wish to set is not supported by this class.
///
@objc public class Query : NSObject, NSCopying {
    
    // MARK: - Low-level (untyped) parameters
    
    /// Parameters, as untyped values.
    private var parameters: [String: String] = [:]
    
    /// Get a parameter in an untyped fashion.
    ///
    /// - parameter name:   The parameter's name.
    /// - returns: The parameter's value, or nil if a parameter with the specified name does not exist.
    ///
    @objc public func get(name: String) -> String? {
        return parameters[name]
    }
    
    /// Set a parameter in an untyped fashion.
    /// This low-level accessor is intended to access parameters that this client does not yet support.
    ///
    /// - parameter name:   The parameter's name.
    /// - parameter value:  The parameter's value, or nill to remove it.
    ///
    @objc public func set(name: String, value: String?) {
        if value == nil {
            parameters.removeValueForKey(name)
        } else {
            parameters[name] = value!
        }
    }
    
    /// Convenience shortcut to `get(_:)` and `set(_:value:)`.
    @objc public subscript(index: String) -> String? {
        get {
            return get(index)
        }
        set(newValue) {
            set(index, value: newValue)
        }
    }
    
    // MARK: -
    
    // MARK: Full text search parameters

    /// The instant-search query string, all words of the query are interpreted as prefixes (for example “John Mc” will
    /// match “John Mccamey” and “Johnathan Mccamey”). If no query parameter is set, retrieves all objects.
    @objc public var query: String? {
        get { return get("query") }
        set { set("query", value: newValue) }
    }
    
    /// Selects how the query words are interpreted:
    /// - `prefixAll`: all query words are interpreted as prefixes
    /// - `prefixLast`: only the last word is interpreted as a prefix (default behavior)
    /// - `prefixNone`: no query word is interpreted as a prefix. This option is not recommended.
    @objc public var queryType: String? {
        get { return queryType_?.rawValue }
        set { queryType_ = newValue == nil ? nil : QueryType(rawValue: newValue!) }
    }
    public enum QueryType: String {
        case PrefixAll = "prefixAll"
        case PrefixLast = "prefixLast"
        case PrefixNone = "prefixNone"
    }
    public var queryType_: QueryType? {
        get {
            if let value = get("queryType") {
                return QueryType(rawValue: value)
            } else {
                return nil
            }
        }
        set {
            set("queryType", value: newValue?.rawValue)
        }
    }
    
    /// This setting has four different options:
    /// - `true`: activate the typo-tolerance.
    /// - `false`: disable the typo-tolerance.
    /// - `min`: keep only results with the lowest number of typo. For example if one result match without typos, then
    ///   all results with typos will be hidden.
    /// - `strict`: if there is a match without typo, then all results with 2 typos or more will be removed. This
    /// option is useful if you want to avoid as much as possible false positive.
    @objc public var typoTolerance: String? {
        get { return typoTolerance_?.rawValue }
        set { typoTolerance_ = newValue == nil ? nil : TypoTolerance(rawValue: newValue!) }
    }
    public enum TypoTolerance: String {
        case True = "true"
        case False = "false"
        case Min = "min"
        case Strict = "strict"
    }
    public var typoTolerance_: TypoTolerance? {
        get {
            if let value = get("typoTolerance") {
                return TypoTolerance(rawValue: value)
            } else {
                return nil
            }
        }
        set {
            set("typoTolerance", value: newValue?.rawValue)
        }
    }
    
    /// The minimum number of characters in a query word to accept one typo in this word.
    @objc public var minWordSizefor1Typo: NSNumber? {
        get { return Query.toNumber(self.minWordSizefor1Typo_) }
        set { self.minWordSizefor1Typo_ = newValue?.unsignedIntegerValue }
    }
    var minWordSizefor1Typo_: UInt? {
        get { return Query.parseUInt(get("minWordSizefor1Typo")) }
        set { set("minWordSizefor1Typo", value: Query.buildUInt(newValue)) }
    }
    
    /// The minimum number of characters in a query word to accept two typos in this word.
    @objc public var minWordSizefor2Typos: NSNumber? {
        get { return Query.toNumber(self.minWordSizefor2Typos_) }
        set { self.minWordSizefor2Typos_ = newValue?.unsignedIntegerValue }
    }
    var minWordSizefor2Typos_: UInt? {
        get { return Query.parseUInt(get("minWordSizefor2Typos")) }
        set { set("minWordSizefor2Typos", value: Query.buildUInt(newValue)) }
    }

    /// If set to false, disable typo-tolerance on numeric tokens (=numbers) in the query word. For example the query
    /// "304" will match with "30450", but not with "40450" that would have been the case with typo-tolerance enabled.
    /// Can be very useful on serial numbers and zip codes searches.
    @objc public var allowTyposOnNumericTokens: NSNumber? {
        get { return Query.toNumber(self.allowTyposOnNumericTokens_) }
        set { self.allowTyposOnNumericTokens_ = newValue?.boolValue }
    }
    var allowTyposOnNumericTokens_: Bool? {
        get { return Query.parseBool(get("allowTyposOnNumericTokens")) }
        set { set("allowTyposOnNumericTokens", value: Query.buildBool(newValue)) }
    }
    
    /// If set to true, simple plural forms won’t be considered as typos (for example car/cars will be considered as
    /// equal).
    @objc public var ignorePlurals: NSNumber? {
        get { return Query.toNumber(self.ignorePlurals_) }
        set { self.ignorePlurals_ = newValue?.boolValue }
    }
    var ignorePlurals_: Bool? {
        get { return Query.parseBool(get("ignorePlurals")) }
        set { set("ignorePlurals", value: Query.buildBool(newValue)) }
    }
    
    /// List of attributes you want to use for textual search (must be a subset of the attributesToIndex index setting).
    /// Attributes are separated with a comma (for example "name,address" ), you can also use a JSON string array
    /// encoding (for example encodeURIComponent('["name","address"]') ). By default, all attributes specified in
    /// attributesToIndex settings are used to search.
    @objc public var restrictSearchableAttributes: [String]? {
        get { return Query.parseStringArray(get("restrictSearchableAttributes")) }
        set { set("restrictSearchableAttributes", value: Query.buildJSONArray(newValue)) }
    }
    
    /// Enable the advanced query syntax.
    @objc public var advancedSyntax: NSNumber? {
        get { return Query.toNumber(self.advancedSyntax_) }
        set { self.advancedSyntax_ = newValue?.boolValue }
    }
    var advancedSyntax_: Bool? {
        get { return Query.parseBool(get("advancedSyntax")) }
        set { set("advancedSyntax", value: Query.buildBool(newValue)) }
    }
    
    /// If set to false, this query will not be taken into account for the Analytics.
    @objc public var analytics: NSNumber? {
        get { return Query.toNumber(self.analytics_) }
        set { self.analytics_ = newValue?.boolValue }
    }
    var analytics_: Bool? {
        get { return Query.parseBool(get("analytics")) }
        set { set("analytics", value: Query.buildBool(newValue)) }
    }
    
    /// If set, tag your query with the specified identifiers. Tags can then be used in the Analytics to analyze a
    /// subset of searches only.
    @objc public var analyticsTags: [String]? {
        get { return Query.parseStringArray(get("analyticsTags")) }
        set { set("analyticsTags", value: Query.buildJSONArray(newValue)) }
    }
    
    /// If set to false, this query will not use synonyms defined in configuration.
    @objc public var synonyms: NSNumber? {
        get { return Query.toNumber(self.synonyms_) }
        set { self.synonyms_ = newValue?.boolValue }
    }
    var synonyms_: Bool? {
        get { return Query.parseBool(get("synonyms")) }
        set { set("synonyms", value: Query.buildBool(newValue)) }
    }
    
    /// If set to false, words matched via synonyms expansion will not be replaced by the matched synonym in the
    /// highlighted result.
    @objc public var replaceSynonymsInHighlight: NSNumber? {
        get { return Query.toNumber(self.replaceSynonymsInHighlight_) }
        set { self.replaceSynonymsInHighlight_ = newValue?.boolValue }
    }
    var replaceSynonymsInHighlight_: Bool? {
        get { return Query.parseBool(get("replaceSynonymsInHighlight")) }
        set { set("replaceSynonymsInHighlight", value: Query.buildBool(newValue)) }
    }
    
    /// Specify a list of words that should be considered as optional when found in the query. This list will be
    /// appended to the one defined in your index settings.
    @objc public var optionalWords: [String]? {
        get { return Query.parseStringArray(get("optionalWords")) }
        set { set("optionalWords", value: Query.buildJSONArray(newValue)) }
    }

    /// Configure the precision of the proximity ranking criterion. By default, the minimum (and best) proximity value
    /// distance between 2 matching words is 1. Setting it to 2 (or 3) would allow 1 (or 2) words to be found between
    /// the matching words without degrading the proximity ranking value.
    ///
    /// Considering the query “javascript framework”, if you set minProximity=2 the records “JavaScript framework” and
    /// “JavaScript charting framework” will get the same proximity score, even if the second one contains a word
    /// between the 2 matching words.
    @objc public var minProximity: NSNumber? {
        get { return Query.toNumber(self.minProximity_) }
        set { self.minProximity_ = newValue?.unsignedIntegerValue }
    }
    var minProximity_: UInt? {
        get { return Query.parseUInt(get("minProximity")) }
        set { set("minProximity", value: Query.buildUInt(newValue)) }
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
    @objc public var removeWordsIfNoResults: String? {
        get { return removeWordsIfNoResults_?.rawValue }
        set { removeWordsIfNoResults_ = newValue == nil ? nil : RemoveWordsIfNoResults(rawValue: newValue!) }
    }
    public enum RemoveWordsIfNoResults: String {
        case None = "none"
        case LastWords = "lastWords"
        case FirstWords = "firstWords"
        case AllOptional = "allOptional"
    }
    public var removeWordsIfNoResults_: RemoveWordsIfNoResults? {
        get {
            if let value = get("removeWordsIfNoResults") {
                return RemoveWordsIfNoResults(rawValue: value)
            } else {
                return nil
            }
        }
        set {
            set("removeWordsIfNoResults", value: newValue?.rawValue)
        }
    }
    
    /// List of attributes on which you want to disable typo tolerance (must be a subset of the `attributesToIndex`
    /// index setting).
    @objc public var disableTypoToleranceOnAttributes: [String]? {
        get { return Query.parseStringArray(get("disableTypoToleranceOnAttributes")) }
        set { set("disableTypoToleranceOnAttributes", value: Query.buildJSONArray(newValue)) }
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
    @objc public var removeStopWords: AnyObject? {
        get {
            let stringValue = get("removeStopWords")
            if let boolValue = Query.parseBool(stringValue) {
                return boolValue
            } else if let arrayValue = Query.parseStringArray(stringValue) {
                return arrayValue
            } else {
                return nil
            }
        }
        set {
            if let boolValue = newValue as? Bool {
                set("removeStopWords", value: Query.buildBool(boolValue))
            } else if let numberValue = newValue as? NSNumber {
                set("removeStopWords", value: Query.buildBool(numberValue.boolValue))
            } else if let arrayValue = newValue as? [String] {
                set("removeStopWords", value: Query.buildStringArray(arrayValue))
            } else {
                set("removeStopWords", value: nil)
            }
        }
    }
    
    /// This parameter control how the exact ranking criterion is computed when the query contains one word.
    @objc public var exactOnSingleWordQuery: String? {
        get { return exactOnSingleWordQuery_?.rawValue }
        set { exactOnSingleWordQuery_ = newValue == nil ? nil : ExactOnSingleWordQuery(rawValue: newValue!) }
    }
    public enum ExactOnSingleWordQuery: String {
        /// No exact on single word query.
        case None = "none"
        /// Exact set to 1 if the query word is found in the record. The query word needs to have at least 3 chars and
        /// not be part of our stop words dictionary.
        case Word = "word"
        /// (Default) Exact set to 1 if there is an attribute containing a string equals to the query.
        case Attribute = "attribute"
    }
    public var exactOnSingleWordQuery_: ExactOnSingleWordQuery? {
        get {
            if let value = get("exactOnSingleWordQuery") {
                return ExactOnSingleWordQuery(rawValue: value)
            } else {
                return nil
            }
        }
        set {
            set("exactOnSingleWordQuery", value: newValue?.rawValue)
        }
    }
    
    /// Specify the list of approximation that should be considered as an exact match in the ranking formula.
    ///
    /// - `ignorePlurals`: alternative word added by the ignore plurals feature
    /// - `singleWordSynonym`: single word synonym (For example “NY” = “NYC”)
    /// - `multiWordsSynonym`: synonym over multiple words (For example “NY” = “New York”)
    ///
    /// The default value is `ignorePlurals,singleWordSynonym`.
    ///
    @objc public var alternativesAsExact: [String]? {
        get { return Query.parseStringArray(get("alternativesAsExact")) }
        set { set("alternativesAsExact", value: newValue?.joinWithSeparator(",")) }
    }
    public enum AlternativesAsExact: String {
        /// Alternative word added by the ignore plurals feature.
        case IgnorePlurals = "ignorePlurals"
        /// Single word synonym (For example “NY” = “NYC”).
        case SingleWordSynonym = "singleWordSynonym"
        /// Synonym over multiple words (For example “NY” = “New York”).
        case MultiWordsSynonym = "multiWordsSynonym"
    }
    public var alternativesAsExact_: [AlternativesAsExact]? {
        get {
            if let rawValues = alternativesAsExact {
                var values = [AlternativesAsExact]()
                for rawValue in rawValues {
                    if let value = AlternativesAsExact(rawValue: rawValue) {
                        values.append(value)
                    }
                }
                return values
            } else {
                return nil
            }
        }
        set {
            var rawValues : [String]?
            if newValue != nil {
                rawValues = []
                for value in newValue! {
                    rawValues?.append(value.rawValue)
                }
            }
            alternativesAsExact = rawValues
        }
    }
    
    // MARK: Pagination parameters
    
    /// Pagination parameter used to select the page to retrieve. Page is zero-based and defaults to 0. Thus, to
    /// retrieve the 10th page you need to set `page=9`
    @objc public var page: NSNumber? {
        get { return Query.toNumber(self.page_) }
        set { self.page_ = newValue?.unsignedIntegerValue }
    }
    var page_: UInt? {
        get { return Query.parseUInt(get("page")) }
        set { set("page", value: Query.buildUInt(newValue)) }
    }
    
    /// Pagination parameter used to select the number of hits per page. Defaults to 20.
    @objc public var hitsPerPage: NSNumber? {
        get { return Query.toNumber(self.hitsPerPage_) }
        set { self.hitsPerPage_ = newValue?.unsignedIntegerValue }
    }
    var hitsPerPage_: UInt? {
        get { return Query.parseUInt(get("hitsPerPage")) }
        set { set("hitsPerPage", value: Query.buildUInt(newValue)) }
    }
    
    // MARK: Parameters to control results content
    
    /// List of object attributes you want to retrieve (let you minimize the answer size). You can also use `*` to
    /// retrieve all values when an `attributesToRetrieve` setting is specified for your index.
    /// By default all attributes are retrieved.
    @objc public var attributesToRetrieve: [String]? {
        get { return Query.parseStringArray(get("attributesToRetrieve")) }
        set { set("attributesToRetrieve", value: Query.buildJSONArray(newValue)) }
    }
    
    /// List of attributes you want to highlight according to the query. If an attribute has no match for the query,
    /// the raw value is returned. By default all indexed text attributes are highlighted. You can use `*` if you want
    /// to highlight all textual attributes. Numerical attributes are not highlighted. A `matchLevel` is returned for
    /// each highlighted attribute and can contain:
    /// - `full`: if all the query terms were found in the attribute
    /// - `partial`: if only some of the query terms were found
    /// - `none`: if none of the query terms were found
    @objc public var attributesToHighlight: [String]? {
        get { return Query.parseStringArray(get("attributesToHighlight")) }
        set { set("attributesToHighlight", value: Query.buildJSONArray(newValue)) }
    }
    
    /// List of attributes to snippet alongside the number of words to return (syntax is `attributeName:nbWords`).
    /// By default no snippet is computed.
    @objc public var attributesToSnippet: [String]? {
        get { return Query.parseStringArray(get("attributesToSnippet")) }
        set { set("attributesToSnippet", value: Query.buildJSONArray(newValue)) }
    }
    
    /// If set to true, the result hits will contain ranking information in `_rankingInfo` attribute.
    @objc public var getRankingInfo: NSNumber? {
        get { return Query.toNumber(self.getRankingInfo_) }
        set { self.getRankingInfo_ = newValue?.boolValue }
    }
    var getRankingInfo_: Bool? {
        get { return Query.parseBool(get("getRankingInfo")) }
        set { set("getRankingInfo", value: Query.buildBool(newValue)) }
    }
    
    /// Specify the string that is inserted before the highlighted parts in the query result (defaults to `<em>`).
    @objc public var highlightPreTag: String? {
        get { return get("highlightPreTag") }
        set { set("highlightPreTag", value: newValue) }
    }
    
    /// Specify the string that is inserted after the highlighted parts in the query result (defaults to `</em>`)
    @objc public var highlightPostTag: String? {
        get { return get("highlightPostTag") }
        set { set("highlightPostTag", value: newValue) }
    }
    
    /// String used as an ellipsis indicator when a snippet is truncated (defaults to empty).
    @objc public var snippetEllipsisText : String? {
        get { return get("snippetEllipsisText") }
        set { set("snippetEllipsisText", value: newValue) }
    }
    
    // MARK: Numeric search parameters

    /// Filter on numeric attributes.
    @objc public var numericFilters: [AnyObject]? {
        get { return Query.parseJSONArray(get("numericFilters")) }
        set { set("numericFilters", value: Query.buildJSONArray(newValue)) }
    }
    
    // MARK: Category search parameters

    /// Filter the query by a set of tags.
    @objc public var tagFilters: [AnyObject]? {
        get { return Query.parseJSONArray(get("tagFilters")) }
        set { set("tagFilters", value: Query.buildJSONArray(newValue)) }
    }
    
    // MARK: Distinct parameter

    /// Enable the distinct feature (disabled by default) if the attributeForDistinct index setting is set. This
    /// feature is similar to the SQL “distinct” keyword: when enabled in a query with the `distinct=1` parameter,
    /// all hits containing a duplicate value for the `attributeForDistinct` attribute are removed from results.
    /// For example, if the chosen attribute is `show_name` and several hits have the same value for `show_name`, then
    /// only the best one is kept and others are removed.
    @objc public var distinct: NSNumber? {
        get { return Query.toNumber(self.distinct_) }
        set { self.distinct_ = newValue?.unsignedIntegerValue }
    }
    var distinct_: UInt? {
        get { return Query.parseUInt(get("distinct")) }
        set { set("distinct", value: Query.buildUInt(newValue)) }
    }
    
    // MARK: Faceting parameters
    
    /// List of object attributes that you want to use for faceting. Only attributes that have been added in
    /// `attributesForFaceting` index setting can be used in this parameter. You can also use `*` to perform faceting
    /// on all attributes specified in `attributesForFaceting`. If the number of results is important, the count can
    /// be approximate, the attribute `exhaustiveFacetsCount` in the response is true when the count is exact.
    @objc public var facets: [String]? {
        get { return Query.parseStringArray(get("facets")) }
        set { set("facets", value: Query.buildJSONArray(newValue)) }
    }
    
    /// Filter the query by a list of facets.
    @objc public var facetFilters: [AnyObject]? {
        get { return Query.parseJSONArray(get("facetFilters")) }
        set { set("facetFilters", value: Query.buildJSONArray(newValue)) }
    }
    
    /// Limit the number of facet values returned for each facet. For example: `maxValuesPerFacet=10` will retrieve
    /// max 10 values per facet.
    @objc public var maxValuesPerFacet: NSNumber? {
        get { return Query.toNumber(self.maxValuesPerFacet_) }
        set { self.maxValuesPerFacet_ = newValue?.unsignedIntegerValue }
    }
    var maxValuesPerFacet_: UInt? {
        get { return Query.parseUInt(get("maxValuesPerFacet")) }
        set { set("maxValuesPerFacet", value: Query.buildUInt(newValue)) }
    }

    // MARK: Unified filter parameter (SQL like)

    /// Filter the query with numeric, facet or/and tag filters.
    /// The syntax is a SQL like syntax, you can use the OR and AND keywords. The syntax for the underlying numeric,
    /// facet and tag filters is the same than in the other filters:
    ///
    ///     available=1 AND (category:Book OR NOT category:Ebook) AND publication_date: 1441745506 TO 1441755506
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
        get { return get("filters") }
        set { set("filters", value: newValue) }
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
            if let fields = get("aroundLatLng")?.componentsSeparatedByString(",") {
                if fields.count == 2 {
                    if let lat = Double(fields[0]), lng = Double(fields[1]) {
                        return LatLng(lat: lat, lng: lng)
                    }
                }
            }
            return nil
        }
        set {
            set("aroundLatLng", value: newValue == nil ? nil : "\(newValue!.lat),\(newValue!.lng)")
        }
    }

    /// Same than aroundLatLng but using IP geolocation instead of manually specified latitude/longitude.
    @objc public var aroundLatLngViaIP: NSNumber? {
        get { return Query.toNumber(self.aroundLatLngViaIP_) }
        set { self.aroundLatLngViaIP_ = newValue?.boolValue }
    }
    var aroundLatLngViaIP_: Bool? {
        get { return Query.parseBool(get("aroundLatLngViaIP")) }
        set { set("aroundLatLngViaIP", value: Query.buildBool(newValue)) }
    }
    
    /// Control the radius associated with a `aroundLatLng` or `aroundLatLngViaIP` query. Defined in meters.
    /// If not set, the radius is computed automatically using the density of the area, you can retrieve the computed
    /// radius in the `automaticRadius` attribute of the answer. You can also specify a minimum value for the automatic
    /// radius by using the `minimumAroundRadius` query parameter. You can specify `aroundRadius=all` if you want to
    /// compute the geo distance without filtering in a geo area, this option will be faster than specifying a big
    /// integer.
    ///
    @objc public var aroundRadius: NSNumber? {
        get { return Query.toNumber(self.aroundRadius_) }
        set { self.aroundRadius_ = newValue?.unsignedIntegerValue }
    }
    var aroundRadius_: UInt? {
        get {
            if let stringValue = get("aroundRadius") {
                if stringValue == "all" {
                    return Query.aroundRadiusAll
                } else {
                    return Query.parseUInt(stringValue)
                }
            } else {
                return nil
            }
        }
        set {
            set("aroundRadius", value: newValue == Query.aroundRadiusAll ? "all" : Query.buildUInt(newValue))
        }
    }
    /// Special value for `aroundRadius` to compute the geo distance without filtering.
    @objc public static let aroundRadiusAll: UInt = UInt.max
    
    /// Control the precision of a `aroundLatLng` query. In meter. For example if you set `aroundPrecision=100`, two
    /// objects that are in the range 0-99m will be considered as identical in the ranking for the .variable geo
    /// ranking parameter (same for 100-199, 200-299, … ranges).
    @objc public var aroundPrecision: NSNumber? {
        get { return Query.toNumber(self.aroundPrecision_) }
        set { self.aroundPrecision_ = newValue?.unsignedIntegerValue }
    }
    var aroundPrecision_: UInt? {
        get { return Query.parseUInt(get("aroundPrecision")) }
        set { set("aroundPrecision", value: Query.buildUInt(newValue)) }
    }

    /// Define the minimum radius used for `aroundLatLng` or `aroundLatLngViaIP` when `aroundRadius` is not set. The
    /// radius is computed automatically using the density of the area. You can retrieve the computed radius in the
    /// `automaticRadius` attribute of the answer.
    @objc public var minimumAroundRadius: NSNumber? {
        get { return Query.toNumber(self.minimumAroundRadius_) }
        set { self.minimumAroundRadius_ = newValue?.unsignedIntegerValue }
    }
    var minimumAroundRadius_: UInt? {
        get { return Query.parseUInt(get("minimumAroundRadius")) }
        set { set("minimumAroundRadius", value: Query.buildUInt(newValue)) }
    }
    
    /// Search for entries inside a given area defined by the two extreme points of a rectangle.
    /// You can use several bounding boxes (OR) by passing more than 1 value.
    @objc public var insideBoundingBox: [GeoRect]? {
        get {
            if let fields = get("insideBoundingBox")?.componentsSeparatedByString(",") {
                if fields.count % 4 == 0 {
                    var result = [GeoRect]()
                    for i in 0..<(fields.count / 4) {
                        if let lat1 = Double(fields[4 * i + 0]), lng1 = Double(fields[4 * i + 1]), lat2 = Double(fields[4 * i + 2]), lng2 = Double(fields[4 * i + 3]) {
                            result.append(GeoRect(p1: LatLng(lat: lat1, lng: lng1), p2: LatLng(lat: lat2, lng: lng2)))
                        }
                    }
                    return result
                }
            }
            return nil
        }
        set {
            if newValue == nil {
                set("insideBoundingBox", value: nil)
            } else {
                var components = [String]()
                for box in newValue! {
                    components.append(String(box.p1.lat))
                    components.append(String(box.p1.lng))
                    components.append(String(box.p2.lat))
                    components.append(String(box.p2.lng))
                }
                set("insideBoundingBox", value: components.joinWithSeparator(","))
            }
        }
    }

    /// Search entries inside a given area defined by a set of points (defined by a minimum of 3 points).
    /// You can pass several time the insidePolygon parameter to your query, the behavior will be a OR between all those polygons.
    // FIXME: Union cannot work with this implementation, as at most one occurrence per parameter is supported.
    @objc public var insidePolygon: [LatLng]? {
        get {
            if let fields = get("insidePolygon")?.componentsSeparatedByString(",") {
                if fields.count % 2 == 0 && fields.count / 2 >= 3 {
                    var result = [LatLng]()
                    for i in 0..<(fields.count / 2) {
                        if let lat = Double(fields[2 * i + 0]), lng = Double(fields[2 * i + 1]) {
                            result.append(LatLng(lat: lat, lng: lng))
                        }
                    }
                    return result
                }
            }
            return nil
        }
        set {
            if newValue == nil {
                set("insidePolygon", value: nil)
            } else {
                assert(newValue!.count >= 3)
                var components = [String]()
                for point in newValue! {
                    components.append(String(point.lat))
                    components.append(String(point.lng))
                }
                set("insidePolygon", value: components.joinWithSeparator(","))
            }
        }
    }

    // MARK: - Miscellaneous

    @objc override public var description: String {
        get { return "Query{\(parameters)}" }
    }
    
    // MARK: - Initialization

    /// Construct an empty query.
    @objc public override init() {
    }
    
    /// Construct a query with the specified full text query.
    @objc public init(query: String?) {
        super.init()
        self.query = query
    }
    
    /// Construct a query with the specified low-level parameters.
    @objc public init(parameters: [String: String]) {
        self.parameters = parameters
    }
    
    /// Clone an existing query.
    @objc public init(copy: Query) {
        parameters = copy.parameters
    }
    
    /// Support for `NSCopying`.
    ///
    /// + Note: Primarily intended for Objective-C use. Swift coders should use `init(copy:)`.
    ///
    @objc public func copyWithZone(zone: NSZone) -> AnyObject {
        // NOTE: As per the docs, the zone argument is ignored.
        return Query(copy: self)
    }

    // MARK: Serialization & parsing

    /// Return the final query string used in URL.
    @objc public func build() -> String {
        var components = [String]()
        // Sort parameters by name to get predictable output.
        let sortedParameters = parameters.sort { $0.0 < $1.0 }
        for (key, value) in sortedParameters {
            let escapedKey = key.urlEncodedQueryParam()
            let escapedValue = value.urlEncodedQueryParam()
            components.append(escapedKey + "=" + escapedValue)
        }
        return components.joinWithSeparator("&")
    }

    /// Parse a query from a URL query string.
    @objc public static func parse(queryString: String) -> Query {
        let query = Query()
        let components = queryString.componentsSeparatedByString("&")
        for component in components {
            let fields = component.componentsSeparatedByString("=")
            if fields.count < 1 || fields.count > 2 {
                continue
            }
            if let name = fields[0].stringByRemovingPercentEncoding {
                let value: String? = fields.count >= 2 ? fields[1].stringByRemovingPercentEncoding : nil
                if value == nil {
                    query.parameters.removeValueForKey(name)
                } else {
                    query.parameters[name] = value!
                }
            }
        }
        return query
    }
    
    // MARK: Equatable
    
    override public func isEqual(object: AnyObject?) -> Bool {
        guard let rhs = object as? Query else {
            return false
        }
        return self.parameters == rhs.parameters
    }
    
    // MARK: - Helper methods to build & parse URL
    
    /// Build a plain, comma-separated array of strings.
    ///
    class func buildStringArray(array: [String]?) -> String? {
        if array != nil {
            return array!.joinWithSeparator(",")
        }
        return nil
    }
    
    class func parseStringArray(string: String?) -> [String]? {
        if string != nil {
            // First try to parse the JSON notation:
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(string!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions(rawValue: 0)) as? [String] {
                    return array
                }
            } catch {
            }
            // Fallback on plain string parsing.
            return string!.componentsSeparatedByString(",")
        }
        return nil
    }
    
    class func buildJSONArray(array: [AnyObject]?) -> String? {
        if array != nil {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(array!, options: NSJSONWritingOptions(rawValue: 0))
                if let string = String(data: data, encoding: NSUTF8StringEncoding) {
                    return string
                }
            } catch {
            }
        }
        return nil
    }
    
    class func parseJSONArray(string: String?) -> [AnyObject]? {
        if string != nil {
            do {
                if let array = try NSJSONSerialization.JSONObjectWithData(string!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions(rawValue: 0)) as? [AnyObject] {
                    return array
                }
            } catch {
            }
        }
        return nil
    }
    
    class func buildUInt(int: UInt?) -> String? {
        return int == nil ? nil : String(int!)
    }
    
    class func parseUInt(string: String?) -> UInt? {
        if string != nil {
            if let intValue = UInt(string!) {
                return intValue
            }
        }
        return nil
    }
    
    class func buildBool(bool: Bool?) -> String? {
        return bool == nil ? nil : String(bool!)
    }
    
    class func parseBool(string: String?) -> Bool? {
        if string != nil {
            switch (string!.lowercaseString) {
                case "true": return true
                case "false": return false
                default:
                    if let intValue = Int(string!) {
                        return intValue != 0
                    }
            }
        }
        return nil
    }
    
    class func toNumber(bool: Bool?) -> NSNumber? {
        return bool == nil ? nil : NSNumber(bool: bool!)
    }

    class func toNumber(int: UInt?) -> NSNumber? {
        return int == nil ? nil : NSNumber(unsignedInteger: int!)
    }
}
