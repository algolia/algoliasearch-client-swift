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


/// A pair of (latitude, longitude).
/// Used in geo-search.
public struct LatLng: Equatable {
    public let lat: Double
    public let lng: Double
    
    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}

public func ==(lhs: LatLng, rhs: LatLng) -> Bool {
    return lhs.lat == rhs.lat && lhs.lng == rhs.lng
}


// ----------------------------------------------------------------------------
// IMPLEMENTATION NOTES
// ----------------------------------------------------------------------------
// # Bridgeability
//
// **This Swift client must be bridgeable to Objective-C.**
//
// Unfortunately, query parameters with primitive types (int, float) are not
// bridgeable, because all parameters are optional, and primitive optionals are
// not bridgeable to Objective-C.
//
// Consequently, for those parameters, another version with type `NSNumber` is
// provided with a trailing underscore appended to the name. Only this version
// is visible from Objective-C.
//
// # Typed vs untyped parameters
//
// All parameters are stored as untyped, string values. They can be
// accessed via the low-level `get` and `set` methods (or the subscript
// operator).
//
// Besides, the class provides typed accessors, acting as wrappers on top
// of the untyped storage (i.e. serializing to and parsing from string
// values).
// ----------------------------------------------------------------------------

/// Describes all parameters of search query.
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
    public func get(name: String) -> String? {
        return parameters[name]
    }
    
    /// Set a parameter by name (untyped version).
    public func set(name: String, value: String?) {
        if value == nil {
            parameters.removeValueForKey(name)
        } else {
            parameters[name] = value!
        }
    }
    
    public subscript(index: String) -> String? {
        get {
            return get(index)
        }
        set(newValue) {
            set(index, value: newValue)
        }
    }
    
    // MARK: - High-level (typed) parameters

    /// The minimum number of characters in a query word to accept one typo in this word.
    public var minWordSizefor1Typo: UInt? {
        get { return Query.parseUInt(get("minWordSizefor1Typo")) }
        set { set("minWordSizefor1Typo", value: Query.buildUInt(newValue)) }
    }
    @objc public var minWordSizefor1Typo_: NSNumber? {
        get { return Query.toNumber(self.minWordSizefor1Typo) }
        set { self.minWordSizefor1Typo = newValue?.unsignedIntegerValue }
    }
    
    /// The minimum number of characters in a query word to accept two typos in this word.
    public var minWordSizefor2Typos: UInt? {
        get { return Query.parseUInt(get("minWordSizefor2Typos")) }
        set { set("minWordSizefor2Typos", value: Query.buildUInt(newValue)) }
    }
    @objc public var minWordSizefor2Typos_: NSNumber? {
        get { return Query.toNumber(self.minWordSizefor2Typos) }
        set { self.minWordSizefor2Typos = newValue?.unsignedIntegerValue }
    }

    /// Configure the precision of the proximity ranking criterion. By default, the minimum (and best) proximity value distance between 2 matching words is 1. Setting it to 2 (or 3) would allow 1 (or 2) words to be found between the matching words without degrading the proximity ranking value.
    /// Considering the query "javascript framework", if you set minProximity=2 the records "JavaScript framework" and "JavaScript charting framework" will get the same proximity score, even if the second one contains a word between the 2 matching words.
    public var minProximity: UInt? {
        get { return Query.parseUInt(get("minProximity")) }
        set { set("minProximity", value: Query.buildUInt(newValue)) }
    }
    @objc public var minProximity_: NSNumber? {
        get { return Query.toNumber(self.minProximity) }
        set { self.minProximity = newValue?.unsignedIntegerValue }
    }
    
    /// If true, the result hits will contain ranking information in _rankingInfo attribute.
    public var getRankingInfo: Bool? {
        get { return Query.parseBool(get("getRankingInfo")) }
        set { set("getRankingInfo", value: Query.buildBool(newValue)) }
    }
    @objc public var getRankingInfo_: NSNumber? {
        get { return Query.toNumber(self.getRankingInfo) }
        set { self.getRankingInfo = newValue?.boolValue }
    }
    
    /// If true, plural won't be considered as a typo (for example car/cars will be considered as equals). 
    public var ignorePlurals: Bool? {
        get { return Query.parseBool(get("ignorePlurals")) }
        set { set("ignorePlurals", value: Query.buildBool(newValue)) }
    }
    @objc public var ignorePlurals_: NSNumber? {
        get { return Query.toNumber(self.ignorePlurals) }
        set { self.ignorePlurals = newValue?.boolValue }
    }
    
    /// Enable the distinct feature (disabled by default) if the attributeForDistinct index setting is set.
    /// This feature is similar to the SQL "distinct" keyword: when enabled in a query, all hits containing a duplicate value 
    /// for the attributeForDistinct attribute are removed from results. For example, if the chosen attribute is show_name 
    /// and several hits have the same value for show_name, then only the best one is kept and others are removed.
    /// Specify the maximum number of hits to keep for each distinct value.
    public var distinct: UInt? {
        get { return Query.parseUInt(get("distinct")) }
        set { set("distinct", value: Query.buildUInt(newValue)) }
    }
    @objc public var distinct_: NSNumber? {
        get { return Query.toNumber(self.distinct) }
        set { self.distinct = newValue?.unsignedIntegerValue }
    }
    
    /// The page to retrieve (zero base). Defaults to 0.
    public var page: UInt? {
        get { return Query.parseUInt(get("page")) }
        set { set("page", value: Query.buildUInt(newValue)) }
    }
    @objc public var page_: NSNumber? {
        get { return Query.toNumber(self.page) }
        set { self.page = newValue?.unsignedIntegerValue }
    }
    
    /// The number of hits per page. Defaults to 20.
    public var hitsPerPage: UInt? {
        get { return Query.parseUInt(get("hitsPerPage")) }
        set { set("hitsPerPage", value: Query.buildUInt(newValue)) }
    }
    @objc public var hitsPerPage_: NSNumber? {
        get { return Query.toNumber(self.hitsPerPage) }
        set { self.hitsPerPage = newValue?.unsignedIntegerValue }
    }

    public var allowTyposOnNumericTokens: Bool? {
        get { return Query.parseBool(get("allowTyposOnNumericTokens")) }
        set { set("allowTyposOnNumericTokens", value: Query.buildBool(newValue)) }
    }
    @objc public var allowTyposOnNumericTokens_: NSNumber? {
        get { return Query.toNumber(self.allowTyposOnNumericTokens) }
        set { self.allowTyposOnNumericTokens = newValue?.boolValue }
    }
    
    /// If false, this query won't appear in the analytics.
    public var analytics: Bool? {
        get { return Query.parseBool(get("analytics")) }
        set { set("analytics", value: Query.buildBool(newValue)) }
    }
    @objc public var analytics_: NSNumber? {
        get { return Query.toNumber(self.analytics) }
        set { self.analytics = newValue?.boolValue }
    }
    
    /// If false, this query will not use synonyms defined in configuration.
    public var synonyms: Bool? {
        get { return Query.parseBool(get("synonyms")) }
        set { set("synonyms", value: Query.buildBool(newValue)) }
    }
    @objc public var synonyms_: NSNumber? {
        get { return Query.toNumber(self.synonyms) }
        set { self.synonyms = newValue?.boolValue }
    }
    
    /// If false, words matched via synonyms expansion will not be replaced by the matched synonym in highlight result. 
    /// Default to true.
    public var replaceSynonymsInHighlight: Bool? {
        get { return Query.parseBool(get("replaceSynonymsInHighlight")) }
        set { set("replaceSynonymsInHighlight", value: Query.buildBool(newValue)) }
    }
    @objc public var replaceSynonymsInHighlight_: NSNumber? {
        get { return Query.toNumber(self.replaceSynonymsInHighlight) }
        set { self.replaceSynonymsInHighlight = newValue?.boolValue }
    }
    
    /// The list of attribute names to highlight.
    /// By default indexed attributes are highlighted.
    public var attributesToHighlight: [String]? {
        get { return Query.parseStringArray(get("attributesToHighlight")) }
        set { set("attributesToHighlight", value: Query.buildStringArray(newValue)) }
    }
    
    /// The list of attribute names to retrieve.
    /// By default all attributes are retrieved.
    public var attributesToRetrieve: [String]? {
        get { return Query.parseStringArray(get("attributesToRetrieve")) }
        set { set("attributesToRetrieve", value: Query.buildStringArray(newValue)) }
    }
    
    /// The full text query.
    public var query: String? {
        get { return get("query") }
        set { set("query", value: newValue) }
    }
    
    /// How the query words are interpreted.
    public var queryType: QueryType? {
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
    // TODO: Objective-C bridging
    
    /// The strategy to avoid having an empty result page.
    public var removeWordsIfNoResults: RemoveWordsIfNoResults? {
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
    // TODO: Objective-C bridging
    
    /// Control the number of typo in the results set.
    public var typoTolerance: TypoTolerance? {
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
    // TODO: Objective-C bridging
    
    /// The list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords').
    /// By default no snippet is computed.
    public var attributesToSnippet: [String]? {
        get { return Query.parseStringArray(get("attributesToSnippet")) }
        set { set("attributesToSnippet", value: Query.buildStringArray(newValue)) }
    }
    
    /// List of object attributes that you want to use for faceting.
    /// Only attributes that have been added in attributesForFaceting index setting can be used in this parameter.
    /// You can also use `*` to perform faceting on all attributes specified in attributesForFaceting.
    public var facets: [String]? {
        get { return Query.parseStringArray(get("facets")) }
        set { set("facets", value: Query.buildStringArray(newValue)) }
    }
    
    /// The list of words that should be considered as optional when found in the query.
    public var optionalWords: [String]? {
        get { return Query.parseStringArray(get("optionalWords")) }
        set { set("optionalWords", value: Query.buildStringArray(newValue)) }
    }
    
    /// List of object attributes you want to use for textual search (must be a subset of the attributesToIndex index setting).
    public var restrictSearchableAttributes: [String]? {
        get { return Query.parseStringArray(get("restrictSearchableAttributes")) }
        set { set("restrictSearchableAttributes", value: Query.buildStringArray(newValue)) }
    }
    
    /// Specify the string that is inserted before the highlighted parts in the query result (default to "<em>").
    public var highlightPreTag: String? {
        get { return get("highlightPreTag") }
        set { set("highlightPreTag", value: newValue) }
    }
    
    /// Specify the string that is inserted after the highlighted parts in the query result (default to "</em>").
    public var highlightPostTag: String? {
        get { return get("highlightPostTag") }
        set { set("highlightPostTag", value: newValue) }
    }
    
    /// Specify the string that is used as an ellipsis indicator when a snippet is truncated (defaults to the empty string).
    public var snippetEllipsisText : String? {
        get { return get("snippetEllipsisText") }
        set { set("snippetEllipsisText", value: newValue) }
    }
    
    /// Tags can be used in the Analytics to analyze a subset of searches only.
    public var analyticsTags: [String]? {
        get { return Query.parseStringArray(get("analyticsTags")) }
        set { set("analyticsTags", value: Query.buildStringArray(newValue)) }
    }
    
    /// Specify the List of attributes on which you want to disable typo tolerance (must be a subset of the attributesToIndex index setting).
    /// By default this list is empty
    public var disableTypoToleranceOnAttributes: [String]? {
        get { return Query.parseStringArray(get("disableTypoToleranceOnAttributes")) }
        set { set("disableTypoToleranceOnAttributes", value: Query.buildStringArray(newValue)) }
    }
    
    /// Change the precision or around latitude/longitude query
    public var aroundPrecision: UInt? {
        get { return Query.parseUInt(get("aroundPrecision")) }
        set { set("aroundPrecision", value: Query.buildUInt(newValue)) }
    }
    @objc public var aroundPrecision_: NSNumber? {
        get { return Query.toNumber(self.aroundPrecision) }
        set { self.aroundPrecision = newValue?.unsignedIntegerValue }
    }

    /// Change the radius or around latitude/longitude query
    public var aroundRadius: UInt? {
        get { return Query.parseUInt(get("aroundRadius")) }
        set { set("aroundRadius", value: Query.buildUInt(newValue)) }
    }
    @objc public var aroundRadius_: NSNumber? {
        get { return Query.toNumber(self.aroundRadius) }
        set { self.aroundRadius = newValue?.unsignedIntegerValue }
    }

    public var aroundLatLngViaIP: Bool? {
        get { return Query.parseBool(get("aroundLatLngViaIP")) }
        set { set("aroundLatLngViaIP", value: Query.buildBool(newValue)) }
    }
    @objc public var aroundLatLngViaIP_: NSNumber? {
        get { return Query.toNumber(self.aroundLatLngViaIP) }
        set { self.aroundLatLngViaIP = newValue?.boolValue }
    }
   
    public var aroundLatLng: LatLng? {
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
    // TODO: Objective-C bridging
    
    public var insideBoundingBox: [LatLng]? {
        get {
            if let fields = get("insideBoundingBox")?.componentsSeparatedByString(",") {
                if fields.count == 4 * 2 {
                    var result = [LatLng]()
                    for var i = 0; i < 4; ++i {
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
    // TODO: Objective-C bridging
    
    public var insidePolygon: [LatLng]? {
        get {
            if let fields = get("insidePolygon")?.componentsSeparatedByString(",") {
                if fields.count % 2 == 0 {
                    var result = [LatLng]()
                    for var i = 0; 2 * i < fields.count; ++i {
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
    // TODO: Objective-C bridging

    // TODO: filters
    // TODO: tagFilters
    // TODO: optionalTagFilters
    // TODO: facetFilters
    // TODO: numericFilters

    // MARK: - Miscellaneous

    override public var description: String {
        get { return "Query = \(build())" }
    }
    
    // MARK: - Initialization

    /// Construct an empty query.
    public override init() {
    }
    
    /// Construct a query with the specified full text query.
    public init(query: String?) {
        super.init()
        self.query = query
    }
    
    /// Construct a query with the specified low-level parameters.
    public init(parameters: [String: String]) {
        self.parameters = parameters
    }
    
    /// Copy an existing query.
    public init(copy: Query) {
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
    public func build() -> String {
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
    public static func parse(queryString: String) -> Query {
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
