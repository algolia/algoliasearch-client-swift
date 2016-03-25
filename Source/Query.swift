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
// Besides, the class provides typed accessors, acting as wrappers on top
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
// IMPLEMENTATION NOTE: Cannot be `struct` because of Objective-C bridgeability.
@objc public class LatLng: NSObject {
    public let lat: Double
    public let lng: Double
    
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


/// Describes all parameters of a search query.
///
/// There are two ways to access parameters:
///
/// 1. Using the high-level, typed properties for individual parameters (recommended).
/// 2. Using the low-level, untyped getter (`get()`) and setter (`set()`) or the subscript operator.
///    Use this approach if the parameter you wish to set is not supported by this class.
///
public class Query : NSObject {
    /// The type of query.
    ///
    /// - PrefixAll: All query words are interpreted as prefixes.
    /// - PrefixLast: Only the last word is interpreted as a prefix (default behavior).
    /// - PrefixNone: No query word is interpreted as a prefix. This option is not recommended.
    public enum QueryType: String {
        case PrefixAll = "prefixAll"
        case PrefixLast = "prefixLast"
        case PrefixNone = "prefixNone"
    }
    
    /// Remove words if no result.
    ///
    /// - None: No specific processing is done when a query does not return any result.
    /// - LastWords: When a query does not return any result, the final word will be removed until there is results.
    /// - FirstWords: When a query does not return any result, the first word will be removed until there is results.
    /// - AllOptional: When a query does not return any result, a second trial will be made with all words as optional (which is equivalent to transforming the AND operand between query terms in a OR operand)
    public enum RemoveWordsIfNoResults: String {
        case None = "none"
        case LastWords = "lastWords"
        case FirstWords = "firstWords"
        case AllOptional = "allOptional"
    }
    
    /// Typo tolerance.
    ///
    /// - Enabled: The typo-tolerance is enabled and all matching hits are retrieved. (Default behavior)
    /// - Disabled: The typo-tolerance is disabled.
    /// - Minimum: Only keep the results with the minimum number of typos.
    /// - Strict: Hits matching with 2 typos are not retrieved if there are some matching without typos.
    public enum TypoTolerance: String {
        case True = "true"
        case False = "false"
        case Min = "min"
        case Strict = "strict"
    }
    
    // MARK: - Low-level (untyped) parameters
    
    /// Parameters, as untyped values.
    private var parameters: [String: String] = [:]
    
    /// Get a parameter by name (untyped version).
    @objc public func get(name: String) -> String? {
        return parameters[name]
    }
    
    /// Set a parameter by name (untyped version).
    @objc public func set(name: String, value: String?) {
        if value == nil {
            parameters.removeValueForKey(name)
        } else {
            parameters[name] = value!
        }
    }
    
    @objc public subscript(index: String) -> String? {
        get {
            return get(index)
        }
        set(newValue) {
            set(index, value: newValue)
        }
    }
    
    // MARK: - High-level (typed) parameters

    /// The minimum number of characters in a query word to accept one typo in this word.
    var minWordSizefor1Typo_: UInt? {
        get { return Query.parseUInt(get("minWordSizefor1Typo")) }
        set { set("minWordSizefor1Typo", value: Query.buildUInt(newValue)) }
    }
    @objc public var minWordSizefor1Typo: NSNumber? {
        get { return Query.toNumber(self.minWordSizefor1Typo_) }
        set { self.minWordSizefor1Typo_ = newValue?.unsignedIntegerValue }
    }
    
    /// The minimum number of characters in a query word to accept two typos in this word.
    var minWordSizefor2Typos_: UInt? {
        get { return Query.parseUInt(get("minWordSizefor2Typos")) }
        set { set("minWordSizefor2Typos", value: Query.buildUInt(newValue)) }
    }
    @objc public var minWordSizefor2Typos: NSNumber? {
        get { return Query.toNumber(self.minWordSizefor2Typos_) }
        set { self.minWordSizefor2Typos_ = newValue?.unsignedIntegerValue }
    }

    /// Configure the precision of the proximity ranking criterion. By default, the minimum (and best) proximity value distance between 2 matching words is 1. Setting it to 2 (or 3) would allow 1 (or 2) words to be found between the matching words without degrading the proximity ranking value.
    /// Considering the query "javascript framework", if you set minProximity=2 the records "JavaScript framework" and "JavaScript charting framework" will get the same proximity score, even if the second one contains a word between the 2 matching words.
    var minProximity_: UInt? {
        get { return Query.parseUInt(get("minProximity")) }
        set { set("minProximity", value: Query.buildUInt(newValue)) }
    }
    @objc public var minProximity: NSNumber? {
        get { return Query.toNumber(self.minProximity_) }
        set { self.minProximity_ = newValue?.unsignedIntegerValue }
    }
    
    /// If true, the result hits will contain ranking information in _rankingInfo attribute.
    var getRankingInfo_: Bool? {
        get { return Query.parseBool(get("getRankingInfo")) }
        set { set("getRankingInfo", value: Query.buildBool(newValue)) }
    }
    @objc public var getRankingInfo: NSNumber? {
        get { return Query.toNumber(self.getRankingInfo_) }
        set { self.getRankingInfo_ = newValue?.boolValue }
    }
    
    /// If true, plural won't be considered as a typo (for example car/cars will be considered as equals). 
    var ignorePlurals_: Bool? {
        get { return Query.parseBool(get("ignorePlurals")) }
        set { set("ignorePlurals", value: Query.buildBool(newValue)) }
    }
    @objc public var ignorePlurals: NSNumber? {
        get { return Query.toNumber(self.ignorePlurals_) }
        set { self.ignorePlurals_ = newValue?.boolValue }
    }
    
    /// Enable the distinct feature (disabled by default) if the attributeForDistinct index setting is set.
    /// This feature is similar to the SQL "distinct" keyword: when enabled in a query, all hits containing a duplicate value 
    /// for the attributeForDistinct attribute are removed from results. For example, if the chosen attribute is show_name 
    /// and several hits have the same value for show_name, then only the best one is kept and others are removed.
    /// Specify the maximum number of hits to keep for each distinct value.
    var distinct_: UInt? {
        get { return Query.parseUInt(get("distinct")) }
        set { set("distinct", value: Query.buildUInt(newValue)) }
    }
    @objc public var distinct: NSNumber? {
        get { return Query.toNumber(self.distinct_) }
        set { self.distinct_ = newValue?.unsignedIntegerValue }
    }
    
    /// The page to retrieve (zero base). Defaults to 0.
    var page_: UInt? {
        get { return Query.parseUInt(get("page")) }
        set { set("page", value: Query.buildUInt(newValue)) }
    }
    @objc public var page: NSNumber? {
        get { return Query.toNumber(self.page_) }
        set { self.page_ = newValue?.unsignedIntegerValue }
    }
    
    /// The number of hits per page. Defaults to 20.
    var hitsPerPage_: UInt? {
        get { return Query.parseUInt(get("hitsPerPage")) }
        set { set("hitsPerPage", value: Query.buildUInt(newValue)) }
    }
    @objc public var hitsPerPage: NSNumber? {
        get { return Query.toNumber(self.hitsPerPage_) }
        set { self.hitsPerPage_ = newValue?.unsignedIntegerValue }
    }

    var allowTyposOnNumericTokens_: Bool? {
        get { return Query.parseBool(get("allowTyposOnNumericTokens")) }
        set { set("allowTyposOnNumericTokens", value: Query.buildBool(newValue)) }
    }
    @objc public var allowTyposOnNumericTokens: NSNumber? {
        get { return Query.toNumber(self.allowTyposOnNumericTokens_) }
        set { self.allowTyposOnNumericTokens_ = newValue?.boolValue }
    }
    
    /// If false, this query won't appear in the analytics.
    var analytics_: Bool? {
        get { return Query.parseBool(get("analytics")) }
        set { set("analytics", value: Query.buildBool(newValue)) }
    }
    @objc public var analytics: NSNumber? {
        get { return Query.toNumber(self.analytics_) }
        set { self.analytics_ = newValue?.boolValue }
    }
    
    /// If false, this query will not use synonyms defined in configuration.
    var synonyms_: Bool? {
        get { return Query.parseBool(get("synonyms")) }
        set { set("synonyms", value: Query.buildBool(newValue)) }
    }
    @objc public var synonyms: NSNumber? {
        get { return Query.toNumber(self.synonyms_) }
        set { self.synonyms_ = newValue?.boolValue }
    }
    
    /// If false, words matched via synonyms expansion will not be replaced by the matched synonym in highlight result. 
    /// Default to true.
    var replaceSynonymsInHighlight_: Bool? {
        get { return Query.parseBool(get("replaceSynonymsInHighlight")) }
        set { set("replaceSynonymsInHighlight", value: Query.buildBool(newValue)) }
    }
    @objc public var replaceSynonymsInHighlight: NSNumber? {
        get { return Query.toNumber(self.replaceSynonymsInHighlight_) }
        set { self.replaceSynonymsInHighlight_ = newValue?.boolValue }
    }
    
    /// The list of attribute names to highlight.
    /// By default indexed attributes are highlighted.
    @objc public var attributesToHighlight: [String]? {
        get { return Query.parseStringArray(get("attributesToHighlight")) }
        set { set("attributesToHighlight", value: Query.buildStringArray(newValue)) }
    }
    
    /// The list of attribute names to retrieve.
    /// By default all attributes are retrieved.
    @objc public var attributesToRetrieve: [String]? {
        get { return Query.parseStringArray(get("attributesToRetrieve")) }
        set { set("attributesToRetrieve", value: Query.buildStringArray(newValue)) }
    }
    
    /// The full text query.
    @objc public var query: String? {
        get { return get("query") }
        set { set("query", value: newValue) }
    }
    
    /// How the query words are interpreted.
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
    @objc public var queryType: String? {
        get { return queryType_?.rawValue }
        set { queryType_ = newValue == nil ? nil : QueryType(rawValue: newValue!) }
    }
    
    /// The strategy to avoid having an empty result page.
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
    @objc public var removeWordsIfNoResults: String? {
        get { return removeWordsIfNoResults_?.rawValue }
        set { removeWordsIfNoResults_ = newValue == nil ? nil : RemoveWordsIfNoResults(rawValue: newValue!) }
    }
    
    /// Control the number of typo in the results set.
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
    @objc public var typoTolerance: String? {
        get { return typoTolerance_?.rawValue }
        set { typoTolerance_ = newValue == nil ? nil : TypoTolerance(rawValue: newValue!) }
    }
    
    /// The list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords').
    /// By default no snippet is computed.
    @objc public var attributesToSnippet: [String]? {
        get { return Query.parseStringArray(get("attributesToSnippet")) }
        set { set("attributesToSnippet", value: Query.buildStringArray(newValue)) }
    }
    
    /// List of object attributes that you want to use for faceting.
    /// Only attributes that have been added in attributesForFaceting index setting can be used in this parameter.
    /// You can also use `*` to perform faceting on all attributes specified in attributesForFaceting.
    @objc public var facets: [String]? {
        get { return Query.parseStringArray(get("facets")) }
        set { set("facets", value: Query.buildStringArray(newValue)) }
    }
    
    /// The list of words that should be considered as optional when found in the query.
    @objc public var optionalWords: [String]? {
        get { return Query.parseStringArray(get("optionalWords")) }
        set { set("optionalWords", value: Query.buildStringArray(newValue)) }
    }
    
    /// List of object attributes you want to use for textual search (must be a subset of the attributesToIndex index setting).
    @objc public var restrictSearchableAttributes: [String]? {
        get { return Query.parseStringArray(get("restrictSearchableAttributes")) }
        set { set("restrictSearchableAttributes", value: Query.buildStringArray(newValue)) }
    }
    
    /// Specify the string that is inserted before the highlighted parts in the query result (default to "<em>").
    @objc public var highlightPreTag: String? {
        get { return get("highlightPreTag") }
        set { set("highlightPreTag", value: newValue) }
    }
    
    /// Specify the string that is inserted after the highlighted parts in the query result (default to "</em>").
    @objc public var highlightPostTag: String? {
        get { return get("highlightPostTag") }
        set { set("highlightPostTag", value: newValue) }
    }
    
    /// Specify the string that is used as an ellipsis indicator when a snippet is truncated (defaults to the empty string).
    @objc public var snippetEllipsisText : String? {
        get { return get("snippetEllipsisText") }
        set { set("snippetEllipsisText", value: newValue) }
    }
    
    /// Tags can be used in the Analytics to analyze a subset of searches only.
    @objc public var analyticsTags: [String]? {
        get { return Query.parseStringArray(get("analyticsTags")) }
        set { set("analyticsTags", value: Query.buildStringArray(newValue)) }
    }
    
    /// Specify the List of attributes on which you want to disable typo tolerance (must be a subset of the attributesToIndex index setting).
    /// By default this list is empty
    @objc public var disableTypoToleranceOnAttributes: [String]? {
        get { return Query.parseStringArray(get("disableTypoToleranceOnAttributes")) }
        set { set("disableTypoToleranceOnAttributes", value: Query.buildStringArray(newValue)) }
    }
    
    /// Change the precision or around latitude/longitude query
    var aroundPrecision_: UInt? {
        get { return Query.parseUInt(get("aroundPrecision")) }
        set { set("aroundPrecision", value: Query.buildUInt(newValue)) }
    }
    @objc public var aroundPrecision: NSNumber? {
        get { return Query.toNumber(self.aroundPrecision_) }
        set { self.aroundPrecision_ = newValue?.unsignedIntegerValue }
    }

    /// Change the radius or around latitude/longitude query
    var aroundRadius_: UInt? {
        get { return Query.parseUInt(get("aroundRadius")) }
        set { set("aroundRadius", value: Query.buildUInt(newValue)) }
    }
    @objc public var aroundRadius: NSNumber? {
        get { return Query.toNumber(self.aroundRadius_) }
        set { self.aroundRadius_ = newValue?.unsignedIntegerValue }
    }

    var aroundLatLngViaIP_: Bool? {
        get { return Query.parseBool(get("aroundLatLngViaIP")) }
        set { set("aroundLatLngViaIP", value: Query.buildBool(newValue)) }
    }
    @objc public var aroundLatLngViaIP: NSNumber? {
        get { return Query.toNumber(self.aroundLatLngViaIP_) }
        set { self.aroundLatLngViaIP_ = newValue?.boolValue }
    }
   
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
    
    @objc public var insideBoundingBox: [LatLng]? {
        get {
            if let fields = get("insideBoundingBox")?.componentsSeparatedByString(",") {
                if fields.count == 4 * 2 {
                    var result = [LatLng]()
                    for i in 0..<4 {
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
            assert(newValue == nil || newValue!.count == 4)
            set("insideBoundingBox", value: newValue == nil ? nil : "\(newValue![0].lat),\(newValue![0].lng),\(newValue![1].lat),\(newValue![1].lng),\(newValue![2].lat),\(newValue![2].lng),\(newValue![3].lat),\(newValue![3].lng)")
        }
    }
    
    @objc public var insidePolygon: [LatLng]? {
        get {
            if let fields = get("insidePolygon")?.componentsSeparatedByString(",") {
                if fields.count % 2 == 0 {
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

    // TODO: filters
    // TODO: tagFilters
    // TODO: optionalTagFilters
    // TODO: facetFilters
    // TODO: numericFilters

    // MARK: - Miscellaneous

    @objc override public var description: String {
        get { return "Query = \(build())" }
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
    
    /// Copy an existing query.
    @objc public init(copy: Query) {
        parameters = copy.parameters
    }

    // MARK: Serialization & parsing

    // Allowed characters taken from [RFC 3986](https://tools.ietf.org/html/rfc3986) (cf. §2 "Characters"):
    // - unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
    // - gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
    // - sub-delims  = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
    //
    // ... with these further restrictions:
    // - ampersand ('&') and equal sign ('=') removed because they are used as delimiters for the parameters;
    // - question mark ('?') and hash ('#') removed because they mark the beginning and the end of the query string.
    //
    static let queryParamAllowedCharacterSet = NSCharacterSet(charactersInString:
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/[]@!$'()*+,;"
    )
    
    /// Return the final query string used in URL.
    @objc public func build() -> String {
        var components = [String]()
        // Sort parameters by name to get predictable output.
        let sortedParameters = parameters.sort { $0.0 < $1.0 }
        for (key, value) in sortedParameters {
            if let escapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(Query.queryParamAllowedCharacterSet),
                let escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(Query.queryParamAllowedCharacterSet) {
                components.append(escapedKey + "=" + escapedValue)
            }
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
    
    class func buildStringArray(array: [String]?) -> String? {
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
