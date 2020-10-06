//
//  QueryTests.swift
//  
//
//  Created by Vladislav Fitc on 09/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class QueryTests: XCTestCase {
  
  let query = Query()
    .set(\.query, to: "testQuery")
    .set(\.similarQuery, to: "testSimilarQuery")
    .set(\.distinct, to: 5)
    .set(\.getRankingInfo, to: true)
    .set(\.explainModules, to: [.matchAlternatives])
    .set(\.attributesToRetrieve, to: ["attr1", "attr2", "attr3"])
    .set(\.restrictSearchableAttributes, to: ["rattr1", "rattr2"])
    .set(\.filters, to: "(color:red OR color:yellow) AND on-sale")
    .set(\.facetFilters, to: [.or("color:red", "color:blue"), "size:M"])
    .set(\.optionalFilters, to: [.or("color:red", "color:yellow"), "on-sale"])
    .set(\.numericFilters, to: [.or("price>100", "length<1000"), "metrics>5"])
    .set(\.tagFilters, to: [.or("tag1", "tag2"), "tag3"])
    .set(\.sumOrFiltersScores, to: false)
    .set(\.facets, to: ["facet1", "facet2", "facet3"])
    .set(\.maxValuesPerFacet, to: 10)
    .set(\.facetingAfterDistinct, to: true)
    .set(\.sortFacetsBy, to: .count)
    .set(\.maxFacetHits, to: 100)
    .set(\.attributesToHighlight, to: ["hattr1", "hattr2", "hattr3"])
    .set(\.attributesToSnippet, to: [Snippet(attribute: "sattr1", count: 10), Snippet(attribute: "sattr2")])
    .set(\.highlightPreTag, to: "<hl>")
    .set(\.highlightPostTag, to: "</hl>")
    .set(\.snippetEllipsisText, to: "read more")
    .set(\.restrictHighlightAndSnippetArrays, to: true)
    .set(\.page, to: 15)
    .set(\.hitsPerPage, to: 30)
    .set(\.offset, to: 100)
    .set(\.length, to: 40)
    .set(\.minWordSizeFor1Typo, to: 2)
    .set(\.minWordSizeFor2Typos, to: 4)
    .set(\.typoTolerance, to: .strict)
    .set(\.allowTyposOnNumericTokens, to: false)
    .set(\.disableTypoToleranceOnAttributes, to: ["dtattr1", "dtattr2"])
    .set(\.aroundLatLng, to: .init(latitude: 79.5, longitude: 10.5))
    .set(\.aroundLatLngViaIP, to: true)
    .set(\.aroundRadius, to: .meters(80))
    .set(\.aroundPrecision, to: [.init(from: 0, value: 1000), .init(from: 0, value: 100000)])
    .set(\.minimumAroundRadius, to: 40)
    .set(\.insideBoundingBox, to: [.init(point1: .init(latitude: 0, longitude: 10), point2: .init(latitude: 20, longitude: 30)), .init(point1: .init(latitude: 40, longitude: 50), point2: .init(latitude: 60, longitude: 70))])
    .set(\.insidePolygon, to: [.init(.init(latitude: 0, longitude: 10), .init(latitude: 20, longitude: 30), .init(latitude: 40, longitude: 50)), .init(.init(latitude: 10, longitude: 20), .init(latitude: 30, longitude: 40), .init(latitude: 50, longitude: 60))])
    .set(\.queryType, to: .prefixLast)
    .set(\.removeWordsIfNoResults, to: .lastWords)
    .set(\.advancedSyntax, to: false)
    .set(\.advancedSyntaxFeatures, to: [.excludeWords, .exactPhrase])
    .set(\.optionalWords, to: ["optWord1", "optWord2"])
    .set(\.removeStopWords, to: .queryLanguages([.arabic, .french]))
    .set(\.disableExactOnAttributes, to: ["deAttr1", "deAttr2"])
    .set(\.exactOnSingleWordQuery, to: .word)
    .set(\.alternativesAsExact, to: [.ignorePlurals, .singleWordSynonym])
    .set(\.ignorePlurals, to: false)
    .set(\.queryLanguages, to: [.hindi, .albanian])
    .set(\.enableRules, to: true)
    .set(\.ruleContexts, to: ["rc1", "rc2"])
    .set(\.enablePersonalization, to: false)
    .set(\.personalizationImpact, to: 5)
    .set(\.userToken, to: "testUserToken")
    .set(\.analytics, to: true)
    .set(\.analyticsTags, to: ["at1", "at2", "at3"])
    .set(\.enableABTest, to: false)
    .set(\.clickAnalytics, to: true)
    .set(\.synonyms, to: false)
    .set(\.replaceSynonymsInHighlight, to: true)
    .set(\.minProximity, to: 3)
    .set(\.responseFields, to: [.facetsStats, .hits])
    .set(\.percentileComputation, to: false)
    .set(\.naturalLanguages, to: [.maori, .tamil])
    .set(\.customParameters, to: ["custom1": "val1", "custom2": 2])


  func testURLStringEncoding() {
    
    let urlEncodedString = query.urlEncodedString
    
    let expectedString = [
      "query=testQuery",
      "similarQuery=testSimilarQuery",
      "distinct=5",
      "getRankingInfo=true",
      "explainModules=match.alternatives",
      "attributesToRetrieve=attr1,attr2,attr3",
      "restrictSearchableAttributes=rattr1,rattr2",
      "filters=(color:red%20OR%20color:yellow)%20AND%20on-sale",
      "facetFilters=%5B%5Bcolor:red,color:blue%5D,size:M%5D",
      "optionalFilters=%5B%5Bcolor:red,color:yellow%5D,on-sale%5D",
      "numericFilters=%5B%5Bprice%3E100,length%3C1000%5D,metrics%3E5%5D",
      "tagFilters=%5B%5Btag1,tag2%5D,tag3%5D",
      "sumOrFiltersScores=false",
      "facets=facet1,facet2,facet3",
      "maxValuesPerFacet=10",
      "facetingAfterDistinct=true",
      "sortFacetValuesBy=count",
      "maxFacetHits=100",
      "attributesToHighlight=hattr1,hattr2,hattr3",
      "attributesToSnippet=sattr1:10,sattr2",
      "highlightPreTag=%3Chl%3E",
      "highlightPostTag=%3C/hl%3E",
      "snippetEllipsisText=read%20more",
      "restrictHighlightAndSnippetArrays=true",
      "page=15",
      "hitsPerPage=30",
      "offset=100",
      "length=40",
      "minWordSizefor1Typo=2",
      "minWordSizefor2Typos=4",
      "typoTolerance=strict",
      "allowTyposOnNumericTokens=false",
      "disableTypoToleranceOnAttributes=dtattr1,dtattr2",
      "aroundLatLng=79.5,10.5",
      "aroundLatLngViaIP=true",
      "aroundRadius=80",
      "aroundPrecision=%5B%7B%22from%22:0.0,%22value%22:1000.0%7D,%7B%22from%22:0.0,%22value%22:100000.0%7D%5D",
      "minimumAroundRadius=40",
      "insideBoundingBox=%5B%5B0.0,10.0,20.0,30.0%5D,%5B40.0,50.0,60.0,70.0%5D%5D",
      "insidePolygon=%5B%5B0.0,10.0,20.0,30.0,40.0,50.0%5D,%5B10.0,20.0,30.0,40.0,50.0,60.0%5D%5D",
      "queryType=prefixLast",
      "removeWordsIfNoResults=lastWords",
      "advancedSyntax=false",
      "advancedSyntaxFeatures=exactPhrase,excludeWords",
      "optionalWords=optWord1,optWord2",
      "removeStopWords=ar,fr",
      "disableExactOnAttributes=deAttr1,deAttr2",
      "exactOnSingleWordQuery=word",
      "alternativesAsExact=ignorePlurals,singleWordSynonym",
      "ignorePlurals=false",
      "queryLanguages=hi,sq",
      "enableRules=true",
      "ruleContexts=rc1,rc2",
      "enablePersonalization=false",
      "personalizationImpact=5",
      "userToken=testUserToken",
      "analytics=true",
      "analyticsTags=at1,at2,at3",
      "enableABTest=false",
      "clickAnalytics=true",
      "synonyms=false",
      "replaceSynonymsInHighlight=true",
      "minProximity=3",
      "responseFields=facets_stats,hits",
      "percentileComputation=false",
      "naturalLanguages=mi,ta",
      "custom1=val1",
      "custom2=2.0"
    ].joined(separator: "&")
    
    XCTAssertEqual(urlEncodedString, expectedString)
  }
  
  func testFacetsCoding() throws {
    let facets: Set<Attribute> = ["facet1", "facet2", "facet3"]
    let query = Query.empty.set(\.facets, to: ["facet1", "facet2", "facet3"])
    let encoder = JSONEncoder()
    let data = try encoder.encode(query)
    let decoder = JSONDecoder()
    let decodedQuery = try decoder.decode(Query.self, from: data)
    XCTAssertEqual(decodedQuery.facets, facets)
    let decodedJSON = try decoder.decode(JSON.self, from: data)
    guard case .dictionary(let dictionary) = decodedJSON else {
      XCTFail("Query in JSON form must be dictionary")
      return
    }
    XCTAssertEqual(dictionary.keys.first, "facets")
    XCTAssertEqual(dictionary.keys.count, 1)
  }
  
  func testCoding() throws {
    try AssertEncodeDecode(query.set(\.facets, to: nil), [
      "query": "testQuery",
      "similarQuery": "testSimilarQuery",
      "distinct": 5,
      "getRankingInfo": true,
      "explainModules": ["match.alternatives"],
      "attributesToRetrieve": ["attr1", "attr2", "attr3"],
      "restrictSearchableAttributes": ["rattr1", "rattr2"],
      "filters": "(color:red OR color:yellow) AND on-sale",
      "facetFilters": [["color:red", "color:blue"], "size:M"],
      "optionalFilters": [["color:red", "color:yellow"], "on-sale"],
      "numericFilters": [["price>100", "length<1000"], "metrics>5"],
      "tagFilters": [["tag1", "tag2"], "tag3"],
      "sumOrFiltersScores": false,
      "maxValuesPerFacet": 10,
      "facetingAfterDistinct": true,
      "sortFacetValuesBy": "count",
      "maxFacetHits": 100,
      "attributesToHighlight": ["hattr1", "hattr2", "hattr3"],
      "attributesToSnippet": ["sattr1:10", "sattr2"],
      "highlightPreTag": "<hl>",
      "highlightPostTag": "</hl>",
      "snippetEllipsisText": "read more",
      "restrictHighlightAndSnippetArrays": true,
      "page": 15,
      "hitsPerPage": 30,
      "offset": 100,
      "length": 40,
      "minWordSizefor1Typo": 2,
      "minWordSizefor2Typos": 4,
      "typoTolerance": "strict",
      "allowTyposOnNumericTokens": false,
      "disableTypoToleranceOnAttributes": ["dtattr1", "dtattr2"],
      "aroundLatLng": "79.5,10.5",
      "aroundLatLngViaIP": true,
      "aroundRadius": "80",
      "aroundPrecision": [["from": 0, "value": 1000], ["from": 0, "value": 100000]],
      "minimumAroundRadius": 40,
      "insideBoundingBox": [[0,10,20,30], [40,50,60,70]],
      "insidePolygon": [[0,10,20,30,40,50], [10,20,30,40,50,60]],
      "queryType": "prefixLast",
      "removeWordsIfNoResults": "lastWords",
      "advancedSyntax": false,
      "advancedSyntaxFeatures": ["excludeWords", "exactPhrase"],
      "optionalWords": ["optWord1", "optWord2"],
      "removeStopWords": ["ar", "fr"],
      "disableExactOnAttributes": ["deAttr1", "deAttr2"],
      "exactOnSingleWordQuery": "word",
      "alternativesAsExact": ["ignorePlurals", "singleWordSynonym"],
      "ignorePlurals": false,
      "queryLanguages": ["hi", "sq"],
      "enableRules": true,
      "ruleContexts": ["rc1", "rc2"],
      "enablePersonalization": false,
      "personalizationImpact": 5,
      "userToken": "testUserToken",
      "analytics": true,
      "analyticsTags": ["at1", "at2", "at3"],
      "enableABTest": false,
      "clickAnalytics": true,
      "synonyms": false,
      "replaceSynonymsInHighlight": true,
      "minProximity": 3,
      "responseFields": ["facets_stats", "hits"],
      "percentileComputation": false,
      "naturalLanguages": ["mi", "ta"],
      "custom1": "val1",
      "custom2": 2,
    ])
  }
  
}
