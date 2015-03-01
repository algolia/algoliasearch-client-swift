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
public class Query : Printable {
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
    
    /// If true, the result hits will contain ranking information in _rankingInfo attribute.
    /// Default to false.
    public var getRankingInfo = false
    
    /// If true, plural won't be considered as a typo (for example car/cars will be considered as equals). 
    /// Default to false.
    public var ignorePlural = false
    
    /// If true, enable the distinct feature (disabled by default) if the attributeForDistinct index setting is set.
    /// This feature is similar to the SQL "distinct" keyword: when enabled in a query, all hits containing a duplicate value 
    /// for the attributeForDistinct attribute are removed from results. For example, if the chosen attribute is show_name 
    /// and several hits have the same value for show_name, then only the best one is kept and others are removed.
    public var distinct = false
    
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
    public var fullTextQuery: String?
    
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
    
    /// List of object attributes you want to use for textual search (must be a subset of the 
    /// attributesToIndex index setting).
    public var restrictSearchableAttributes: [String]?
    
    private var aroundLatLongViaIP = false
    private var aroundLatLong: String?
    private var insideBoundingBox: String?
    
    public var description: String {
        get { return "Query = \(buildURL())" }
    }
    
    // MARK: - Methods
    
    public init(fullTextQuery: String? = nil) {
        self.fullTextQuery = fullTextQuery
    }
    
    /// Search for entries around a given latitude/longitude.
    ///
    /// :param: maxDistance set the maximum distance in meters.
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing 
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchAroundLatitude(latitude: Float, longitude: Float, maxDistance maxDist: UInt) {
        aroundLatLong = "aroundLatLng=\(latitude),\(longitude)&aroundRadius=\(maxDist)"
    }
    
    /// Search for entries around a given latitude/longitude.
    ///
    /// :param: maxDistance set the maximum distance in meters.
    /// :param: precision set the precision for ranking (for example if you set precision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchAroundLatitude(latitude: Float, longitude: Float, maxDistance maxDist: UInt, precision: UInt) {
        aroundLatLong = "aroundLatLng=\(latitude),\(longitude)&aroundRadius=\(maxDist)&aroundPrecision=\(precision)"
    }
    
    /// Search for entries around a given latitude/longitude (using IP geolocation).
    ///
    /// :param: maxDistance set the maximum distance in meters.
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchAroundLatitudeLongitudeViaIP(maxDistance maxDist: UInt) {
        aroundLatLong = "aroundRadius=\(maxDist)"
        aroundLatLongViaIP = true
    }
    
    /// Search for entries around a given latitude/longitude (using IP geolocation).
    ///
    /// :param: maxDistance set the maximum distance in meters.
    /// :param: precision set the precision for ranking (for example if you set precision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchAroundLatitudeLongitudeViaIP(maxDistane maxDist: UInt, precision: UInt) {
        aroundLatLong = "aroundRadius=\(maxDist)&aroundPrecision=\(precision)"
        aroundLatLongViaIP = true
    }
    
    /// Search for entries inside a given area defined by the two extreme points of a rectangle.
    ///
    /// Note: at indexing, geoloc of an object should be set with _geoloc attribute containing
    /// lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    public func searchInsideBoundingBoxWithLatitudeP1(latitudeP1: Float, longitudeP1: Float, latitudeP2: Float, longitudeP2: Float) {
        insideBoundingBox = "insideBoundingBox=\(latitudeP1),\(longitudeP1),\(latitudeP2),\(longitudeP2)"
    }
    
    /// Return the final query string used in URL.
    public func buildURL() -> String {
        var url = [String]()
        if let attributesToRetrieve = attributesToRetrieve {
            url.append(Query.encodeForQuery(attributesToRetrieve, withKey: "attributes"))
        }
        if let attributesToHighlight = attributesToHighlight {
            url.append(Query.encodeForQuery(attributesToHighlight, withKey: "attributesToHighlight"))
        }
        if let attributesToSnippet = attributesToSnippet {
            url.append(Query.encodeForQuery(attributesToSnippet, withKey: "attributesToSnippet"))
        }
        
        if let facetFilters = facetFilters {
            var error: NSError?
            let data = NSJSONSerialization.dataWithJSONObject(facetFilters, options: .PrettyPrinted, error: &error)
            if error == nil {
                let json: String = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                url.append(Query.encodeForQuery(json, withKey: "facetFilters"))
            } else {
                NSException(name: "InvalidArgument", reason: "Invalid facetFilters (should be an array of string)", userInfo: nil).raise()
            }
        } else if let facetFiltersRaw = facetFiltersRaw {
            url.append(Query.encodeForQuery(facetFiltersRaw, withKey: "facetFilters"))
        }
        
        if let facets = facets {
            url.append(Query.encodeForQuery(facets, withKey: "facets"))
        }
        if let optionalWords = optionalWords {
            url.append(Query.encodeForQuery(optionalWords, withKey: "optionalWords"))
        }
        if optionalWordsMinimumMatched > 0 {
            url.append(Query.encodeForQuery(optionalWordsMinimumMatched, withKey: "optionalWordsMinimumMatched"))
        }
        if minWordSizeForApprox1 != 3 {
            url.append(Query.encodeForQuery(minWordSizeForApprox1, withKey: "minWordSizefor1Typo"))
        }
        if minWordSizeForApprox2 != 7 {
            url.append(Query.encodeForQuery(minWordSizeForApprox2, withKey: "minWordSizefor2Typos"))
        }
        if ignorePlural {
            url.append(Query.encodeForQuery(ignorePlural, withKey: "ignorePlural"))
        }
        if getRankingInfo {
            url.append(Query.encodeForQuery(getRankingInfo, withKey: "getRankingInfo"))
        }
        if !typosOnNumericTokens { // default True
            url.append(Query.encodeForQuery(typosOnNumericTokens, withKey: "allowTyposOnNumericTokens"))
        }
        if let typoTolerance = typoTolerance {
            url.append(Query.encodeForQuery(typoTolerance, withKey: "typoTolerance"))
        }
        if distinct {
            url.append(Query.encodeForQuery(distinct, withKey: "distinct"))
        }
        if !analytics { // default True
            url.append(Query.encodeForQuery(analytics, withKey: "analytics"))
        }
        if !synonyms { // default True
            url.append(Query.encodeForQuery(synonyms, withKey: "synonyms"))
        }
        if !replaceSynonyms { // default True
            url.append(Query.encodeForQuery(replaceSynonyms, withKey: "replaceSynonymsInHighlight"))
        }
        if page > 0 {
            url.append(Query.encodeForQuery(page, withKey: "page"))
        }
        if hitsPerPage != 20 && hitsPerPage > 0 {
            url.append(Query.encodeForQuery(hitsPerPage, withKey: "hitsPerPage"))
        }
        if let queryType = queryType {
            url.append(Query.encodeForQuery(queryType, withKey: "queryType"))
        }
        if let removeWordsIfNoResult = removeWordsIfNoResult {
            url.append(Query.encodeForQuery(removeWordsIfNoResult, withKey: "removeWordsIfNoResult"))
        }
        if let tagFilters = tagFilters {
            url.append(Query.encodeForQuery(tagFilters, withKey: "tagFilters"))
        }
        if let numericFilters = numericFilters {
            url.append(Query.encodeForQuery(numericFilters, withKey: "numericFilters"))
        }
        
        if let insideBoundingBox = insideBoundingBox {
            url.append(insideBoundingBox)
        } else if let aroundLatLong = aroundLatLong {
            url.append(aroundLatLong)
        }
        
        if aroundLatLongViaIP {
            url.append(Query.encodeForQuery(aroundLatLongViaIP, withKey: "aroundLatLngViaIP"))
        }
        if let fullTextQuery = fullTextQuery {
            url.append(Query.encodeForQuery(fullTextQuery, withKey: "query"))
        }
        if let restrictSearchableAttributes = restrictSearchableAttributes {
            url.append(Query.encodeForQuery(restrictSearchableAttributes, withKey: "restrictSearchableAttributes"))
        }
        
        return "&".join(url)
    }
    
    // MARK: - Helper methods to build URL
    
    class func encodeForQuery(elements: [String], withKey key: String) -> String {
        return "\(key)=" + ",".join(elements.map { $0.urlEncode() })
    }
    
    class func encodeForQuery(element: String, withKey key: String) -> String {
        return "\(key)=\(element.urlEncode())"
    }
    
    class func encodeForQuery<T>(element: T, withKey key: String) -> String {
        return "\(key)=\(element)"
    }
}