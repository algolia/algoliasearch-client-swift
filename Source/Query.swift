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

// TODO: rethink attributes. Use for example enum for queryType
// TODO: add comment for all attributes

/// Describes all parameters of search query.
public class Query : Printable {
    public var minWordSizeForApprox1: UInt = 3
    public var minWordSizeForApprox2: UInt = 7
    public var getRankingInfo = false
    public var ignorePlural = false
    public var distinct = false
    public var page: UInt = 0
    public var hitsPerPage: UInt = 20
    public var typosOnNumericTokens = true
    public var analytics = true
    public var synonyms = true
    public var replaceSynonyms = true
    public var optionalWordsMinimumMatched: UInt = 0
    public var attributesToHighlight: [String]?
    public var attributesToRetrieve: [String]?
    public var tagFilters: String?
    public var numericFilters: String?
    public var fullTextQuery: String?
    public var queryType: String?
    public var removeWordsIfNoResult: String?
    public var typoTolerance: String?
    public var attributesToSnippet: [String]?
    public var facetFilters: [String]?
    public var facetFiltersRaw: String?
    public var facets: [String]?
    public var optionalWords: [String]?
    public var restrictSearchableAttributes: String?
    
    private var aroundLatLongViaIP = false
    private var aroundLatLong: String?
    private var insideBoundingBox: String?
    
    public var description: String {
        get { return "Query = \(buildURL())" }
    }
    
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
            url.append(encodeForQuery(attributesToRetrieve, key: "attributes"))
        }
        if let attributesToHighlight = attributesToHighlight {
            url.append(encodeForQuery(attributesToHighlight, key: "attributesToHighlight"))
        }
        if let attributesToSnippet = attributesToSnippet {
            url.append(encodeForQuery(attributesToSnippet, key: "attributesToSnippet"))
        }
        
        if let facetFilters = facetFilters {
            // TODO: complete code (JSON)
        } else if let facetFiltersRaw = facetFiltersRaw {
            url.append(encodeForQuery(facetFiltersRaw, key: "facetFilters="))
        }
        
        if let facets = facets {
            url.append(encodeForQuery(facets, key: "facets"))
        }
        if let optionalWords = optionalWords {
            url.append(encodeForQuery(optionalWords, key: "optionalWords"))
        }
        if optionalWordsMinimumMatched > 0 {
            url.append(encodeForQuery(optionalWordsMinimumMatched, key: "optionalWordsMinimumMatched"))
        }
        if minWordSizeForApprox1 != 3 {
            url.append(encodeForQuery(minWordSizeForApprox1, key: "minWordSizefor1Typo"))
        }
        if minWordSizeForApprox2 != 7 {
            url.append(encodeForQuery(minWordSizeForApprox2, key: "minWordSizefor2Typos"))
        }
        if ignorePlural {
            url.append(encodeForQuery(ignorePlural, key: "ignorePlural"))
        }
        if getRankingInfo {
            url.append(encodeForQuery(getRankingInfo, key: "getRankingInfo"))
        }
        if !typosOnNumericTokens { // default True
            url.append(encodeForQuery(typosOnNumericTokens, key: "allowTyposOnNumericTokens"))
        }
        if let typoTolerance = typoTolerance {
            url.append(encodeForQuery(typoTolerance, key: "typoTolerance"))
        }
        if distinct {
            url.append(encodeForQuery(distinct, key: "distinct"))
        }
        if !analytics { // default True
            url.append(encodeForQuery(analytics, key: "analytics"))
        }
        if !synonyms { // default True
            url.append(encodeForQuery(synonyms, key: "synonyms"))
        }
        if !replaceSynonyms { // default True
            url.append(encodeForQuery(replaceSynonyms, key: "replaceSynonymsInHighlight"))
        }
        if page > 0 {
            url.append(encodeForQuery(page, key: "page"))
        }
        if hitsPerPage != 20 && hitsPerPage > 0 {
            url.append(encodeForQuery(hitsPerPage, key: "hitsPerPage"))
        }
        if let queryType = queryType {
            url.append(encodeForQuery(queryType, key: "queryType"))
        }
        if let removeWordsIfNoResult = removeWordsIfNoResult {
            url.append(encodeForQuery(removeWordsIfNoResult, key: "removeWordsIfNoResult"))
        }
        if let tagFilters = tagFilters {
            url.append(encodeForQuery(tagFilters, key: "tagFilters"))
        }
        if let numericFilters = numericFilters {
            url.append(encodeForQuery(numericFilters, key: "numericFilters"))
        }
        
        if let insideBoundingBox = insideBoundingBox {
            url.append(insideBoundingBox)
        } else if let aroundLatLong = aroundLatLong {
            url.append(aroundLatLong)
        }
        
        if aroundLatLongViaIP {
            url.append(encodeForQuery(aroundLatLongViaIP, key: "aroundLatLngViaIP"))
        }
        if let fullTextQuery = fullTextQuery {
            url.append(encodeForQuery(fullTextQuery, key: "query"))
        }
        if let restrictSearchableAttributes = restrictSearchableAttributes {
            url.append(encodeForQuery(restrictSearchableAttributes, key: "restrictSearchableAttributes"))
        }
        
        return "&".join(url)
    }
    
    // MARK: - Private methods
    
    private func encodeForQuery(elements: [String], key: String) -> String {
        return "\(key)=" + ",".join(elements.map { $0.urlEncode() })
    }
    
    private func encodeForQuery(element: String, key: String) -> String {
        return "\(key)=\(element.urlEncode())"
    }
    
    private func encodeForQuery<T>(element: T, key: String) -> String {
        return "\(key)=\(element)"
    }
}