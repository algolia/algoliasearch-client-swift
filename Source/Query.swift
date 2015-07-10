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
    public enum RemoveWordsIfNoResult: String {
        case None = "None"
        case LastWords = "LastWords"
        case FirstWords = "FirstWords"
        case AllOptional = "allOptional"
    }
    
    /// Typo tolerance.
    ///
    /// - Enabled: The typo-tolerance is enabled and all matching hits are retrieved. (Default behavior)
    /// - Disabled: The typo-tolerance is disabled.
    /// - Minimum: Only keep the results with the minimum number of typos.
    /// - Strict: Hits matching with 2 typos are not retrieved if there are some matching without typos.
    public enum TypoTolerance: String {
        case Enabled = "true"
        case Disabled = "false"
        case Minimum = "min"
        case Strict = "strict"
    }
    
    // MARK: - Properties
    
    /// The minimum number of characters in a query word to accept one typo in this word.
    /// Defaults to 3.
    public var minWordSizeForApprox1: UInt = 3
    
    /// The minimum number of characters in a query word to accept two typos in this word.
    /// Defaults to 7.
    public var minWordSizeForApprox2: UInt = 7
    
    /// Configure the precision of the proximity ranking criterion. By default, the minimum (and best) proximity value distance between 2 matching words is 1. Setting it to 2 (or 3) would allow 1 (or 2) words to be found between the matching words without degrading the proximity ranking value.
    /// Considering the query "javascript framework", if you set minProximity=2 the records "JavaScript framework" and "JavaScript charting framework" will get the same proximity score, even if the second one contains a word between the 2 matching words.
    public var minProximity: UInt = 1
    
    /// If true, the result hits will contain ranking information in _rankingInfo attribute.
    /// Default to false.
    public var getRankingInfo = false
    
    /// If true, plural won't be considered as a typo (for example car/cars will be considered as equals). 
    /// Default to false.
    public var ignorePlural = false
    
    /// Enable the distinct feature (disabled by default) if the attributeForDistinct index setting is set.
    /// This feature is similar to the SQL "distinct" keyword: when enabled in a query, all hits containing a duplicate value 
    /// for the attributeForDistinct attribute are removed from results. For example, if the chosen attribute is show_name 
    /// and several hits have the same value for show_name, then only the best one is kept and others are removed.
    /// Specify the maximum number of hits to keep for each distinct value.
    public var distinct: UInt = 0
    
    /// The page to retrieve (zero base). Defaults to 0.
    public var page: UInt = 0
    
    /// The number of hits per page. Defaults to 20.
    public var hitsPerPage: UInt = 20
    
    /// If false, disable typo-tolerance on numeric tokens. Default to true.
    public var typosOnNumericTokens = true
    
    /// If false, this query won't appear in the analytics. Default to true.
    public var analytics = true
    
    /// If false, this query will not use synonyms defined in configuration. Default to true.
    public var synonyms = true
    
    /// If false, words matched via synonyms expansion will not be replaced by the matched synonym in highlight result. 
    /// Default to true.
    public var replaceSynonyms = true
    
    /// The list of attribute names to highlight.
    /// By default indexed attributes are highlighted.
    public var attributesToHighlight: [String]?
    
    /// The list of attribute names to retrieve.
    /// By default all attributes are retrieved.
    public var attributesToRetrieve: [String]?
    
    /// Filter the query by a set of tags. You can AND tags by separating them by commas. 
    /// To OR tags, you must add parentheses. For example tag1,(tag2,tag3) means tag1 AND (tag2 OR tag3).
    /// At indexing, tags should be added in the _tags attribute of objects (for example {"_tags":["tag1","tag2"]} ).
    public var tagFilters: String?
    
    /// A list of numeric filters.
    /// The syntax of one filter is `attributeName` followed by `operand` followed by `value. Supported operands are `<`, `<=`, `=`, `>` and `>=`.
    /// You can have multiple conditions on one attribute like for example `numerics=price>100,price<1000`.
    public var numericFilters: [String]?
    
    /// The full text query.
    public var query: String?
    
    /// How the query words are interpreted.
    public var queryType: QueryType?
    
    /// The strategy to avoid having an empty result page.
    public var removeWordsIfNoResult: RemoveWordsIfNoResult?
    
    /// Control the number of typo in the results set.
    public var typoTolerance: TypoTolerance?
    
    /// The list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords').
    /// By default no snippet is computed.
    public var attributesToSnippet: [String]?
    
    /// Filter the query by a list of facets. Each facet is encoded as `attributeName:value`. 
    /// For example: ["category:Book","author:John%20Doe"].
    public var facetFilters: [String]?
    
    /// Filter the query by a list of facets encoded as one string by example "(category:Book,author:John)".
    public var facetFiltersRaw: String?
    
    /// List of object attributes that you want to use for faceting.
    /// Only attributes that have been added in attributesForFaceting index setting can be used in this parameter.
    /// You can also use `*` to perform faceting on all attributes specified in attributesForFaceting.
    public var facets: [String]?
    
    /// The minimum number of optional words that need to match. Defaults to 0.
    public var optionalWordsMinimumMatched: UInt = 0
    
    /// The list of words that should be considered as optional when found in the query.
    public var optionalWords: [String]?
    
    /// List of object attributes you want to use for textual search (must be a subset of the attributesToIndex index setting).
    public var restrictSearchableAttributes: [String]?
    
    /// Specify the string that is inserted before the highlighted parts in the query result (default to "<em>").
    public var highlightPreTag: String?
    
    /// Specify the string that is inserted after the highlighted parts in the query result (default to "</em>").
    public var highlightPostTag: String?
    
    /// Tags can be used in the Analytics to analyze a subset of searches only.
    public var analyticsTags: [String]?
    
    var aroundLatLongViaIP = false
    var aroundLatLong: String?
    var insideBoundingBox: String?
    
    override public var description: String {
        get { return "Query = \(buildURL())" }
    }
    
    @availability(*, deprecated=1.2.1, message="Use the new API: Query.query: String?")
    public var fullTextQuery: String? {
        get {
            return query
        }
        set {
            query = newValue
        }
    }
    
    // MARK: - Methods
    
    @availability(*, deprecated=1.2.1, message="Use the new API: Query(query: String?)")
    public init(fullTextQuery: String) {
        self.query = fullTextQuery
    }
    
    public init(query: String? = nil) {
        self.query = query
    }
    
    /// Copy all the attributes and return a new instance
    public init(copy: Query) {
        minWordSizeForApprox1 = copy.minWordSizeForApprox1
        minWordSizeForApprox2 = copy.minWordSizeForApprox2
        minProximity = copy.minProximity
        getRankingInfo = copy.getRankingInfo
        ignorePlural = copy.ignorePlural
        distinct = copy.distinct
        page = copy.page
        hitsPerPage = copy.hitsPerPage
        typosOnNumericTokens = copy.typosOnNumericTokens
        analytics = copy.analytics
        synonyms = copy.synonyms
        replaceSynonyms = copy.replaceSynonyms
        attributesToHighlight = copy.attributesToHighlight
        attributesToRetrieve = copy.attributesToRetrieve
        tagFilters = copy.tagFilters
        numericFilters = copy.numericFilters
        query = copy.query
        queryType = copy.queryType
        removeWordsIfNoResult = copy.removeWordsIfNoResult
        typoTolerance = copy.typoTolerance
        attributesToSnippet = copy.attributesToSnippet
        facetFilters = copy.facetFilters
        facetFiltersRaw = copy.facetFiltersRaw
        facets = copy.facets
        optionalWordsMinimumMatched = copy.optionalWordsMinimumMatched
        optionalWords = copy.optionalWords
        restrictSearchableAttributes = copy.restrictSearchableAttributes
        highlightPreTag = copy.highlightPreTag
        highlightPostTag = copy.highlightPostTag
        aroundLatLongViaIP = copy.aroundLatLongViaIP
        aroundLatLong = copy.aroundLatLong
        insideBoundingBox = copy.insideBoundingBox
        analyticsTags = copy.analyticsTags
    }
    
    /// Search for entries around a given latitude/longitude.
    ///
    /// :param: maxDistance set the maximum distance in meters.
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing 
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchAroundLatitude(latitude: Float, longitude: Float, maxDistance maxDist: UInt) -> Query {
        aroundLatLong = "aroundLatLng=\(latitude),\(longitude)&aroundRadius=\(maxDist)"
        return self
    }
    
    /// Search for entries around a given latitude/longitude.
    ///
    /// :param: maxDistance set the maximum distance in meters.
    /// :param: precision set the precision for ranking (for example if you set precision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchAroundLatitude(latitude: Float, longitude: Float, maxDistance maxDist: UInt, precision: UInt) -> Query {
        aroundLatLong = "aroundLatLng=\(latitude),\(longitude)&aroundRadius=\(maxDist)&aroundPrecision=\(precision)"
        return self
    }
    
    /// Search for entries around a given latitude/longitude (using IP geolocation).
    ///
    /// :param: maxDistance set the maximum distance in meters.
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchAroundLatitudeLongitudeViaIP(maxDistance maxDist: UInt) -> Query {
        aroundLatLong = "aroundRadius=\(maxDist)"
        aroundLatLongViaIP = true
        return self
    }
    
    /// Search for entries around a given latitude/longitude (using IP geolocation).
    ///
    /// :param: maxDistance set the maximum distance in meters.
    /// :param: precision set the precision for ranking (for example if you set precision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchAroundLatitudeLongitudeViaIP(maxDistane maxDist: UInt, precision: UInt) -> Query {
        aroundLatLong = "aroundRadius=\(maxDist)&aroundPrecision=\(precision)"
        aroundLatLongViaIP = true
        return self
    }
    
    /// Search for entries inside a given area defined by the two extreme points of a rectangle.
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchInsideBoundingBoxWithLatitudeP1(latitudeP1: Float, longitudeP1: Float, latitudeP2: Float, longitudeP2: Float) -> Query {
        insideBoundingBox = "insideBoundingBox=\(latitudeP1),\(longitudeP1),\(latitudeP2),\(longitudeP2)"
        return self
    }
    
    /// Reset location parameters (aroundLatLong,insideBoundingBox, aroundLatLongViaIP set to false)
    public func resetLocationParameters() -> Query {
        aroundLatLong = nil
        insideBoundingBox = nil
        aroundLatLongViaIP = false
        return self
    }
    
    /// Return the final query string used in URL.
    public func buildURL() -> String {
        var url = [String]()
        if let attributesToRetrieve = attributesToRetrieve {
            url.append(Query.encodeArrayForQuery(attributesToRetrieve, withKey: "attributes"))
        }
        if let attributesToHighlight = attributesToHighlight {
            url.append(Query.encodeArrayForQuery(attributesToHighlight, withKey: "attributesToHighlight"))
        }
        if let attributesToSnippet = attributesToSnippet {
            url.append(Query.encodeArrayForQuery(attributesToSnippet, withKey: "attributesToSnippet"))
        }
        
        if let facetFilters = facetFilters {
            var error: NSError?
            let data = NSJSONSerialization.dataWithJSONObject(facetFilters, options: .PrettyPrinted, error: &error)
            if error == nil {
                let json: String = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
                url.append(Query.encodeStringForQuery(json, withKey: "facetFilters"))
            } else {
                NSException(name: "InvalidArgument", reason: "Invalid facetFilters (should be an array of string)", userInfo: nil).raise()
            }
        } else if let facetFiltersRaw = facetFiltersRaw {
            url.append(Query.encodeStringForQuery(facetFiltersRaw, withKey: "facetFilters"))
        }
        
        if let facets = facets {
            url.append(Query.encodeArrayForQuery(facets, withKey: "facets"))
        }
        if let optionalWords = optionalWords {
            url.append(Query.encodeArrayForQuery(optionalWords, withKey: "optionalWords"))
        }
        if optionalWordsMinimumMatched > 0 {
            url.append(Query.encodeUIntegerForQuery(optionalWordsMinimumMatched, withKey: "optionalWordsMinimumMatched"))
        }
        if minWordSizeForApprox1 != 3 {
            url.append(Query.encodeUIntegerForQuery(minWordSizeForApprox1, withKey: "minWordSizefor1Typo"))
        }
        if minWordSizeForApprox2 != 7 {
            url.append(Query.encodeUIntegerForQuery(minWordSizeForApprox2, withKey: "minWordSizefor2Typos"))
        }
        if ignorePlural {
            url.append(Query.encodeBoolForQuery(ignorePlural, withKey: "ignorePlural"))
        }
        if getRankingInfo {
            url.append(Query.encodeBoolForQuery(getRankingInfo, withKey: "getRankingInfo"))
        }
        if !typosOnNumericTokens { // default True
            url.append(Query.encodeBoolForQuery(typosOnNumericTokens, withKey: "allowTyposOnNumericTokens"))
        }
        if let typoTolerance = typoTolerance {
            url.append(Query.encodeStringForQuery(typoTolerance.rawValue, withKey: "typoTolerance"))
        }
        if distinct > 0 {
            url.append(Query.encodeUIntegerForQuery(distinct, withKey: "distinct"))
        }
        if !analytics { // default True
            url.append(Query.encodeBoolForQuery(analytics, withKey: "analytics"))
        }
        if !synonyms { // default True
            url.append(Query.encodeBoolForQuery(synonyms, withKey: "synonyms"))
        }
        if !replaceSynonyms { // default True
            url.append(Query.encodeBoolForQuery(replaceSynonyms, withKey: "replaceSynonymsInHighlight"))
        }
        if page > 0 {
            url.append(Query.encodeUIntegerForQuery(page, withKey: "page"))
        }
        if hitsPerPage != 20 && hitsPerPage > 0 {
            url.append(Query.encodeUIntegerForQuery(hitsPerPage, withKey: "hitsPerPage"))
        }
        if minProximity > 1 {
            url.append(Query.encodeUIntegerForQuery(minProximity, withKey: "minProximity"))
        }
        if let queryType = queryType {
            url.append(Query.encodeStringForQuery(queryType.rawValue, withKey: "queryType"))
        }
        if let removeWordsIfNoResult = removeWordsIfNoResult {
            url.append(Query.encodeStringForQuery(removeWordsIfNoResult.rawValue, withKey: "removeWordsIfNoResult"))
        }
        if let tagFilters = tagFilters {
            url.append(Query.encodeStringForQuery(tagFilters, withKey: "tagFilters"))
        }
        if let numericFilters = numericFilters {
            url.append(Query.encodeArrayForQuery(numericFilters, withKey: "numericFilters"))
        }
        if let highlightPreTag = highlightPreTag, highlightPostTag = highlightPostTag {
            url.append(Query.encodeStringForQuery(highlightPreTag, withKey: "highlightPreTag"))
            url.append(Query.encodeStringForQuery(highlightPostTag, withKey: "highlightPostTag"))
        }
        
        if let insideBoundingBox = insideBoundingBox {
            url.append(insideBoundingBox)
        } else if let aroundLatLong = aroundLatLong {
            url.append(aroundLatLong)
        }
        
        if aroundLatLongViaIP {
            url.append(Query.encodeBoolForQuery(aroundLatLongViaIP, withKey: "aroundLatLngViaIP"))
        }
        if let query = query {
            url.append(Query.encodeStringForQuery(query, withKey: "query"))
        }
        if let restrictSearchableAttributes = restrictSearchableAttributes {
            url.append(Query.encodeArrayForQuery(restrictSearchableAttributes, withKey: "restrictSearchableAttributes"))
        }
        if let analyticsTags = analyticsTags {
            url.append(Query.encodeArrayForQuery(analyticsTags, withKey: "analyticsTags"))
        }
        
        return "&".join(url)
    }
    
    // MARK: - Helper methods to build URL
    
    class func encodeArrayForQuery(elements: [String], withKey key: String) -> String {
        return "\(key)=" + ",".join(elements.map { $0.urlEncode() })
    }
    
    class func encodeStringForQuery(element: String, withKey key: String) -> String {
        return "\(key)=\(element.urlEncode())"
    }
    
    class func encodeIntegerForQuery(element: Int, withKey key: String) -> String {
        return "\(key)=\(element)"
    }
    
    class func encodeUIntegerForQuery(element: UInt, withKey key: String) -> String {
        return "\(key)=\(element)"
    }
    
    class func encodeBoolForQuery(element: Bool, withKey key: String) -> String {
        return "\(key)=\(element)"
    }

    
//    class func encodeForQuery(elements: [String], withKey key: String) -> String {
//        return "\(key)=" + ",".join(elements.map { $0.urlEncode() })
//    }
//    
//    class func encodeForQuery(element: String, withKey key: String) -> String {
//        return "\(key)=\(element.urlEncode())"
//    }
//    
//    class func encodeForQuery<T>(element: T, withKey key: String) -> String {
//        return "\(key)=\(element)"
//    }
}