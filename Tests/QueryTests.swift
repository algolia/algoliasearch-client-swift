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

import AlgoliaSearch
import XCTest

class QueryTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Build & parse
    
    /// Test serializing a query into a URL query string.
    func testBuild() {
        let query = Query()
        query["c"] = "C"
        query["b"] = "B"
        query["a"] = "A"
        let queryString = query.build()
        XCTAssertEqual(queryString, "a=A&b=B&c=C")
    }

    /// Test parsing a query from a URL query string.
    func testParse() {
        // Build the URL for a query.
        let query1 = Query()
        query1["foo"] = "bar"
        query1["abc"] = "xyz"
        let queryString = query1.build()
        
        // Parse the URL into another query.
        let query2 = Query.parse(queryString)
        XCTAssertEqual(query1, query2)
    }

    /// Test that non-ASCII and special characters are escaped.
    func testEscape() {
        let query1 = Query()
        query1["accented"] = "éêèàôù"
        query1["escaped"] = " %&=#+"
        let queryString = query1.build()
        XCTAssertEqual(queryString, "accented=%C3%A9%C3%AA%C3%A8%C3%A0%C3%B4%C3%B9&escaped=%20%25%26%3D%23%2B")
        
        // Test parsing of escaped characters.
        let query2 = Query.parse(queryString)
        XCTAssertEqual(query1, query2)
    }
    
    // MARK: Low-level
    
    /// Test low-level accessors.
    func testGetSet() {
        let query = Query()
        
        // Test accessors.
        query.setParameter(withName: "a", to: "A")
        XCTAssertEqual(query.parameter(withName: "a"), "A")
        
        // Test subscript.
        query["b"] = "B"
        XCTAssertEqual(query["b"], "B")

        // Test subscript and accessors equivalence.
        query.setParameter(withName: "c", to: "C")
        XCTAssertEqual(query["c"], "C")
        query["d"] = "D"
        XCTAssertEqual(query.parameter(withName: "d"), "D")

        // Test setting nil.
        query.setParameter(withName: "a", to: nil)
        XCTAssertNil(query.parameter(withName: "a"))
        query["b"] = nil
        XCTAssertNil(query["b"])
    }
    
    // MARK: KVO
    
    func testKVO() {
        let query = Query()
        query.addObserver(self, forKeyPath: "hitsPerPage", options: [.new, .old], context: nil)
        query.addObserver(self, forKeyPath: "attributesToRetrieve", options: [.new, .old], context: nil)
        defer {
            query.removeObserver(self, forKeyPath: "hitsPerPage")
            query.removeObserver(self, forKeyPath: "attributesToRetrieve")
        }
        query.hitsPerPage = 666
        query.hitsPerPage = 666 // setting the same value again should not trigger any call
        query.hitsPerPage = nil
        query.attributesToRetrieve = ["abc", "xyz"]
        query.attributesToRetrieve = ["abc", "xyz"] // setting the same value again should not trigger any call
        query.attributesToRetrieve = nil
        XCTAssertEqual(4, iteration)
    }

    /// Tracks the number of calls to `observeValue(forKeyPath:of:change:context:)`.
    var iteration: Int = 0
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        iteration += 1
        switch iteration {
        case 1:
            XCTAssertEqual(keyPath, "hitsPerPage")
            let old = change![.oldKey] as? Int
            let new = change![.newKey] as? Int
            XCTAssert(nil == old)
            XCTAssertEqual(666, new)
        case 2:
            XCTAssertEqual(keyPath, "hitsPerPage")
            let old = change![.oldKey] as? Int
            let new = change![.newKey] as? Int
            XCTAssertEqual(666, old)
            XCTAssert(nil == new)
        case 3:
            XCTAssertEqual(keyPath, "attributesToRetrieve")
            let old = change![.oldKey] as? [String]
            let new = change![.newKey] as? [String]
            XCTAssert(nil == old)
            XCTAssertEqual(["abc", "xyz"], new!)
        case 4:
            XCTAssertEqual(keyPath, "attributesToRetrieve")
            let old = change![.oldKey] as? [String]
            let new = change![.newKey] as? [String]
            XCTAssertEqual(["abc", "xyz"], old!)
            XCTAssert(nil == new)
        default:
            XCTFail("Unexpected call to `observeValue(forKeyPath:of:change:context:)`")
        }
    }

    // MARK: High-level

    func test_minWordSizefor1Typo() {
        let query1 = Query()
        XCTAssertNil(query1.minWordSizefor1Typo)
        query1.minWordSizefor1Typo = 123
        XCTAssertEqual(query1.minWordSizefor1Typo, 123)
        XCTAssertEqual(query1["minWordSizefor1Typo"], "123")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.minWordSizefor1Typo, 123)
    }

    func test_minWordSizefor2Typos() {
        let query1 = Query()
        XCTAssertNil(query1.minWordSizefor2Typos)
        query1.minWordSizefor2Typos = 456
        XCTAssertEqual(query1.minWordSizefor2Typos, 456)
        XCTAssertEqual(query1["minWordSizefor2Typos"], "456")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.minWordSizefor2Typos, 456)
    }

    func test_minProximity() {
        let query1 = Query()
        XCTAssertNil(query1.minProximity)
        query1.minProximity = 999
        XCTAssertEqual(query1.minProximity, 999)
        XCTAssertEqual(query1["minProximity"], "999")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.minProximity, 999)
    }

    func test_getRankingInfo() {
        let query1 = Query()
        XCTAssertNil(query1.getRankingInfo)
        query1.getRankingInfo = true
        XCTAssertEqual(query1.getRankingInfo, true)
        XCTAssertEqual(query1["getRankingInfo"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.getRankingInfo, true)

        query1.getRankingInfo = false
        XCTAssertEqual(query1.getRankingInfo, false)
        XCTAssertEqual(query1["getRankingInfo"], "false")
        let query3 = Query.parse(query1.build())
        XCTAssertEqual(query3.getRankingInfo, false)
    }

    func test_ignorePlurals() {
        let query1 = Query()
        XCTAssertNil(query1.ignorePlurals)

        query1.ignorePlurals = .all(true)
        XCTAssertEqual(query1.ignorePlurals, .all(true))
        XCTAssertEqual(query1["ignorePlurals"], "true")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.ignorePlurals, .all(true))
        
        query1.ignorePlurals = .all(false)
        XCTAssertEqual(query1.ignorePlurals, .all(false))
        XCTAssertEqual(query1["ignorePlurals"], "false")
        let query3 = Query.parse(query1.build())
        XCTAssertEqual(query3.ignorePlurals, .all(false))

        let VALUE = ["de", "en", "fr"]
        query1.ignorePlurals = .selected(VALUE)
        XCTAssertEqual(query1.ignorePlurals, .selected(VALUE))
        XCTAssertEqual(query1["ignorePlurals"], "de,en,fr")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.ignorePlurals, .selected(VALUE))
        
        // WARNING: There's no validation of ISO codes, so any string is interpreted as a single code.
        query1["ignorePlurals"] = "invalid"
        XCTAssertNotNil(query1.ignorePlurals)
        switch query1.ignorePlurals! {
        case let .selected(values): XCTAssertEqual(1, values.count)
        default: XCTFail()
        }
    }

    func test_distinct() {
        let query1 = Query()
        XCTAssertNil(query1.distinct)
        query1.distinct = 100
        XCTAssertEqual(query1.distinct, 100)
        XCTAssertEqual(query1["distinct"], "100")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.distinct, 100)
    }

    func test_page() {
        let query1 = Query()
        XCTAssertNil(query1.page)
        query1.page = 0
        XCTAssertEqual(query1.page, 0)
        XCTAssertEqual(query1["page"], "0")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.page, 0)
    }

    func test_hitsPerPage() {
        let query1 = Query()
        XCTAssertNil(query1.hitsPerPage)
        query1.hitsPerPage = 50
        XCTAssertEqual(query1.hitsPerPage, 50)
        XCTAssertEqual(query1["hitsPerPage"], "50")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.hitsPerPage, 50)
    }
    
    func test_offset() {
        let query1 = Query()
        XCTAssertNil(query1.offset)
        query1.offset = 4
        XCTAssertEqual(query1.offset, 4)
        XCTAssertEqual(query1["offset"], "4")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.offset, 4)
    }
    
    func test_length() {
        let query1 = Query()
        XCTAssertNil(query1.length)
        query1.length = 4
        XCTAssertEqual(query1.length, 4)
        XCTAssertEqual(query1["length"], "4")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.length, 4)
    }
    
    func test_allowTyposOnNumericTokens() {
        let query1 = Query()
        XCTAssertNil(query1.allowTyposOnNumericTokens)
        query1.allowTyposOnNumericTokens = true
        XCTAssertEqual(query1.allowTyposOnNumericTokens, true)
        XCTAssertEqual(query1["allowTyposOnNumericTokens"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.allowTyposOnNumericTokens, true)
        
        query1.allowTyposOnNumericTokens = false
        XCTAssertEqual(query1.allowTyposOnNumericTokens, false)
        XCTAssertEqual(query1["allowTyposOnNumericTokens"], "false")
        let query3 = Query.parse(query1.build())
        XCTAssertEqual(query3.allowTyposOnNumericTokens, false)
    }

    func test_analytics() {
        let query1 = Query()
        XCTAssertNil(query1.analytics)
        query1.analytics = true
        XCTAssertEqual(query1.analytics, true)
        XCTAssertEqual(query1["analytics"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.analytics, true)
    }
    
    func test_synonyms() {
        let query1 = Query()
        XCTAssertNil(query1.synonyms)
        query1.synonyms = true
        XCTAssertEqual(query1.synonyms, true)
        XCTAssertEqual(query1["synonyms"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.synonyms, true)
    }

    func test_attributesToHighlight() {
        let query1 = Query()
        XCTAssertNil(query1.attributesToHighlight)
        query1.attributesToHighlight = ["foo", "bar"]
        XCTAssertEqual(query1.attributesToHighlight!, ["foo", "bar"])
        XCTAssertEqual(query1["attributesToHighlight"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.attributesToHighlight!, ["foo", "bar"])
    }

    func test_attributesToRetrieve() {
        let query1 = Query()
        XCTAssertNil(query1.attributesToRetrieve)
        query1.attributesToRetrieve = ["foo", "bar"]
        XCTAssertEqual(query1.attributesToRetrieve!, ["foo", "bar"])
        XCTAssertEqual(query1["attributesToRetrieve"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.attributesToRetrieve!, ["foo", "bar"])
    }

    func test_attributesToSnippet() {
        let query1 = Query()
        XCTAssertNil(query1.attributesToSnippet)
        query1.attributesToSnippet = ["foo:3", "bar:7"]
        XCTAssertEqual(query1.attributesToSnippet!, ["foo:3", "bar:7"])
        XCTAssertEqual(query1["attributesToSnippet"], "[\"foo:3\",\"bar:7\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.attributesToSnippet!, ["foo:3", "bar:7"])
    }

    func test_query() {
        let query1 = Query()
        XCTAssertNil(query1.query)
        query1.query = "supercalifragilisticexpialidocious"
        XCTAssertEqual(query1.query, "supercalifragilisticexpialidocious")
        XCTAssertEqual(query1["query"], "supercalifragilisticexpialidocious")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.query, "supercalifragilisticexpialidocious")
    }
    
    func test_queryType() {
        let query1 = Query()
        XCTAssertNil(query1.queryType)

        query1.queryType = .prefixAll
        XCTAssertEqual(query1.queryType, .prefixAll)
        XCTAssertEqual(query1["queryType"], "prefixAll")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.queryType, .prefixAll)

        query1.queryType = .prefixLast
        XCTAssertEqual(query1.queryType, .prefixLast)
        XCTAssertEqual(query1["queryType"], "prefixLast")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.queryType, .prefixLast)

        query1.queryType = .prefixNone
        XCTAssertEqual(query1.queryType, .prefixNone)
        XCTAssertEqual(query1["queryType"], "prefixNone")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.queryType, .prefixNone)

        query1["queryType"] = "invalid"
        XCTAssertNil(query1.queryType)
    }

    func test_removeWordsIfNoResults() {
        let query1 = Query()
        XCTAssertNil(query1.removeWordsIfNoResults)
        
        query1.removeWordsIfNoResults = .allOptional
        XCTAssertEqual(query1.removeWordsIfNoResults, .allOptional)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "allOptional")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeWordsIfNoResults, .allOptional)
        
        query1.removeWordsIfNoResults = .firstWords
        XCTAssertEqual(query1.removeWordsIfNoResults, .firstWords)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "firstWords")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeWordsIfNoResults, .firstWords)
        
        query1.removeWordsIfNoResults = .lastWords
        XCTAssertEqual(query1.removeWordsIfNoResults, .lastWords)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "lastWords")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeWordsIfNoResults, .lastWords)
        
        query1.removeWordsIfNoResults = Query.RemoveWordsIfNoResults.none // WARNING: Possible confusion with `Optional.none`!
        XCTAssertEqual(query1.removeWordsIfNoResults, Query.RemoveWordsIfNoResults.none)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "none")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeWordsIfNoResults, Query.RemoveWordsIfNoResults.none)
        
        query1["removeWordsIfNoResults"] = "invalid"
        XCTAssertNil(query1.removeWordsIfNoResults)
    }
    
    func test_typoTolerance() {
        let query1 = Query()
        XCTAssertNil(query1.typoTolerance)
        
        query1.typoTolerance = .true
        XCTAssertEqual(query1.typoTolerance, .true)
        XCTAssertEqual(query1["typoTolerance"], "true")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.typoTolerance, .true)
        
        query1.typoTolerance = .false
        XCTAssertEqual(query1.typoTolerance, .false)
        XCTAssertEqual(query1["typoTolerance"], "false")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.typoTolerance, .false)
        
        query1.typoTolerance = .min
        XCTAssertEqual(query1.typoTolerance, .min)
        XCTAssertEqual(query1["typoTolerance"], "min")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.typoTolerance, .min)
        
        query1.typoTolerance = .strict
        XCTAssertEqual(query1.typoTolerance, .strict)
        XCTAssertEqual(query1["typoTolerance"], "strict")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.typoTolerance, .strict)
        
        query1["typoTolerance"] = "invalid"
        XCTAssertNil(query1.typoTolerance)
    }

    func test_facets() {
        let query1 = Query()
        XCTAssertNil(query1.facets)
        query1.facets = ["foo", "bar"]
        XCTAssertEqual(query1.facets!, ["foo", "bar"])
        XCTAssertEqual(query1["facets"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.facets!, ["foo", "bar"])
    }

    func test_optionalWords() {
        let query1 = Query()
        XCTAssertNil(query1.optionalWords)
        query1.optionalWords = ["foo", "bar"]
        XCTAssertEqual(query1.optionalWords!, ["foo", "bar"])
        XCTAssertEqual(query1["optionalWords"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.optionalWords!, ["foo", "bar"])
    }

    func test_restrictSearchableAttributes() {
        let query1 = Query()
        XCTAssertNil(query1.restrictSearchableAttributes)
        query1.restrictSearchableAttributes = ["foo", "bar"]
        XCTAssertEqual(query1.restrictSearchableAttributes!, ["foo", "bar"])
        XCTAssertEqual(query1["restrictSearchableAttributes"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.restrictSearchableAttributes!, ["foo", "bar"])
    }

    func test_highlightPreTag() {
        let query1 = Query()
        XCTAssertNil(query1.highlightPreTag)
        query1.highlightPreTag = "<PRE["
        XCTAssertEqual(query1.highlightPreTag, "<PRE[")
        XCTAssertEqual(query1["highlightPreTag"], "<PRE[")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.highlightPreTag, "<PRE[")
    }
    
    func test_highlightPostTag() {
        let query1 = Query()
        XCTAssertNil(query1.highlightPostTag)
        query1.highlightPostTag = "]POST>"
        XCTAssertEqual(query1.highlightPostTag, "]POST>")
        XCTAssertEqual(query1["highlightPostTag"], "]POST>")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.highlightPostTag, "]POST>")
    }
    
    func test_snippetEllipsisText() {
        let query1 = Query()
        XCTAssertNil(query1.snippetEllipsisText)
        query1.snippetEllipsisText = "…"
        XCTAssertEqual(query1.snippetEllipsisText, "…")
        XCTAssertEqual(query1["snippetEllipsisText"], "…")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.snippetEllipsisText, "…")
    }
    
    func test_restrictHighlightAndSnippetArrays() {
        let query1 = Query()
        XCTAssertNil(query1.restrictHighlightAndSnippetArrays)
        query1.restrictHighlightAndSnippetArrays = false
        XCTAssertEqual(query1.restrictHighlightAndSnippetArrays, false)
        XCTAssertEqual(query1["restrictHighlightAndSnippetArrays"], "false")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.restrictHighlightAndSnippetArrays, false)
    }
    
    func test_analyticsTags() {
        let query1 = Query()
        XCTAssertNil(query1.analyticsTags)
        query1.analyticsTags = ["foo", "bar"]
        XCTAssertEqual(query1.analyticsTags!, ["foo", "bar"])
        XCTAssertEqual(query1["analyticsTags"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.analyticsTags!, ["foo", "bar"])
    }
    
    func test_disableTypoToleranceOnAttributes() {
        let query1 = Query()
        XCTAssertNil(query1.disableTypoToleranceOnAttributes)
        query1.disableTypoToleranceOnAttributes = ["foo", "bar"]
        XCTAssertEqual(query1.disableTypoToleranceOnAttributes!, ["foo", "bar"])
        XCTAssertEqual(query1["disableTypoToleranceOnAttributes"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.disableTypoToleranceOnAttributes!, ["foo", "bar"])
    }

    func test_aroundPrecision() {
        let query1 = Query()
        XCTAssertNil(query1.aroundPrecision)
        query1.aroundPrecision = 12345
        XCTAssertEqual(query1.aroundPrecision, 12345)
        XCTAssertEqual(query1["aroundPrecision"], "12345")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundPrecision, 12345)
    }
    
    func test_aroundRadius() {
        let query1 = Query()
        XCTAssertNil(query1.aroundRadius)
        query1.aroundRadius = .explicit(987)
        XCTAssertEqual(query1.aroundRadius, .explicit(987))
        XCTAssertEqual(query1["aroundRadius"], "987")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundRadius, .explicit(987))
        
        query1.aroundRadius = .all
        XCTAssertEqual(query1.aroundRadius, .all)
        XCTAssertEqual(query1["aroundRadius"], "all")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundRadius, .all)
    }
    
    func test_aroundLatLngViaIP() {
        let query1 = Query()
        XCTAssertNil(query1.aroundLatLngViaIP)
        query1.aroundLatLngViaIP = true
        XCTAssertEqual(query1.aroundLatLngViaIP, true)
        XCTAssertEqual(query1["aroundLatLngViaIP"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundLatLngViaIP, true)
    }
    
    func test_aroundLatLng() {
        let query1 = Query()
        XCTAssertNil(query1.aroundLatLng)
        query1.aroundLatLng = LatLng(lat: 89.76, lng: -123.45)
        XCTAssertEqual(query1.aroundLatLng!, LatLng(lat: 89.76, lng: -123.45))
        XCTAssertEqual(query1["aroundLatLng"], "89.76,-123.45")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundLatLng!, LatLng(lat: 89.76, lng: -123.45))
    }
    
    func test_insideBoundingBox() {
        let query1 = Query()
        XCTAssertNil(query1.insideBoundingBox)
        let box1 = GeoRect(p1: LatLng(lat: 11.111111, lng: 22.222222), p2: LatLng(lat: 33.333333, lng: 44.444444))
        query1.insideBoundingBox = [box1]
        XCTAssertEqual(query1.insideBoundingBox!, [box1])
        XCTAssertEqual(query1["insideBoundingBox"], "11.111111,22.222222,33.333333,44.444444")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.insideBoundingBox!, [box1])
        
        let box2 = GeoRect(p1: LatLng(lat: -55.555555, lng: -66.666666), p2: LatLng(lat: -77.777777, lng: -88.888888))
        let boxes = [box1, box2]
        query1.insideBoundingBox = boxes
        XCTAssertEqual(query1.insideBoundingBox!, boxes)
        XCTAssertEqual(query1["insideBoundingBox"], "11.111111,22.222222,33.333333,44.444444,-55.555555,-66.666666,-77.777777,-88.888888")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.insideBoundingBox!, boxes)
    }

    func test_insidePolygon() {
        let query1 = Query()
        XCTAssertNil(query1.insidePolygon)
        let POLYGONS: [[LatLng]] = [
            [LatLng(lat: 11.111111, lng: 22.222222), LatLng(lat: 33.333333, lng: 44.444444), LatLng(lat: -55.555555, lng: -66.666667)],
            [LatLng(lat: -77.777777, lng: -88.888887), LatLng(lat: 11.111111, lng: 22.222222), LatLng(lat: 0, lng: 0)]
        ]
        query1.insidePolygon = POLYGONS
        XCTAssertEqual(query1.insidePolygon! as NSObject, POLYGONS as NSObject)
        XCTAssertEqual(query1["insidePolygon"], "[[11.111111,22.222222,33.333333,44.444444,-55.555555,-66.666667],[-77.777777,-88.888887,11.111111,22.222222,0,0]]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.insidePolygon! as NSObject, POLYGONS as NSObject)
    }

    func test_tagFilters() {
        let VALUE: [Any] = ["tag1", ["tag2", "tag3"]]
        let query1 = Query()
        XCTAssertNil(query1.tagFilters)
        query1.tagFilters = VALUE
        XCTAssertEqual(query1.tagFilters! as NSObject, VALUE as NSObject)
        XCTAssertEqual(query1["tagFilters"], "[\"tag1\",[\"tag2\",\"tag3\"]]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.tagFilters! as NSObject, VALUE as NSObject)
    }
    
    func test_facetFilters() {
        let VALUE: [Any] = [["category:Book", "category:Movie"], "author:John Doe"]
        let query1 = Query()
        XCTAssertNil(query1.facetFilters)
        query1.facetFilters = VALUE
        XCTAssertEqual(query1.facetFilters! as NSObject, VALUE as NSObject)
        XCTAssertEqual(query1["facetFilters"], "[[\"category:Book\",\"category:Movie\"],\"author:John Doe\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.facetFilters! as NSObject, VALUE as NSObject)
    }

    func test_advancedSyntax() {
        let query1 = Query()
        XCTAssertNil(query1.advancedSyntax)
        query1.advancedSyntax = true
        XCTAssertEqual(query1.advancedSyntax, true)
        XCTAssertEqual(query1["advancedSyntax"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.advancedSyntax, true)
    }

    func test_removeStopWords() {
        let query1 = Query()
        XCTAssertNil(query1.removeStopWords)
        query1.removeStopWords = .all(true)
        XCTAssertEqual(query1.removeStopWords, .all(true))
        XCTAssertEqual(query1["removeStopWords"], "true")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeStopWords, .all(true))

        query1.removeStopWords = .all(false)
        XCTAssertEqual(query1.removeStopWords, .all(false))
        XCTAssertEqual(query1["removeStopWords"], "false")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeStopWords, .all(false))

        let VALUE = ["de", "es", "fr"]
        query1.removeStopWords = .selected(VALUE)
        XCTAssertEqual(query1.removeStopWords, .selected(VALUE))
        XCTAssertEqual(query1["removeStopWords"], "de,es,fr")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeStopWords, .selected(VALUE))
        
        // WARNING: There's no validation of ISO codes, so any string is interpreted as a single code.
        query1["removeStopWords"] = "invalid"
        XCTAssertNotNil(query1.removeStopWords)
        switch query1.removeStopWords! {
        case let .selected(values): XCTAssertEqual(1, values.count)
        default: XCTFail()
        }
    }
    
    func test_maxValuesPerFacet() {
        let query1 = Query()
        XCTAssertNil(query1.maxValuesPerFacet)
        query1.maxValuesPerFacet = 456
        XCTAssertEqual(query1.maxValuesPerFacet, 456)
        XCTAssertEqual(query1["maxValuesPerFacet"], "456")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.maxValuesPerFacet, 456)
    }
    
    func test_minimumAroundRadius() {
        let query1 = Query()
        XCTAssertNil(query1.minimumAroundRadius)
        query1.minimumAroundRadius = 1000
        XCTAssertEqual(query1.minimumAroundRadius, 1000)
        XCTAssertEqual(query1["minimumAroundRadius"], "1000")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.minimumAroundRadius, 1000)
    }
    
    func test_numericFilters() {
        let VALUE: [Any] = ["code=1", ["price:0 to 10", "price:1000 to 2000"]]
        let query1 = Query()
        XCTAssertNil(query1.numericFilters)
        query1.numericFilters = VALUE
        XCTAssertEqual(query1.numericFilters! as NSObject, VALUE as NSObject)
        XCTAssertEqual(query1["numericFilters"], "[\"code=1\",[\"price:0 to 10\",\"price:1000 to 2000\"]]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.numericFilters! as NSObject, VALUE as NSObject)
    }
    
    func test_filters() {
        let VALUE = "available=1 AND (category:Book OR NOT category:Ebook) AND publication_date: 1441745506 TO 1441755506 AND inStock > 0 AND author:\"John Doe\""
        let query1 = Query()
        XCTAssertNil(query1.filters)
        query1.filters = VALUE
        XCTAssertEqual(query1.filters, VALUE)
        XCTAssertEqual(query1["filters"], VALUE)
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.filters, VALUE)
    }
    
    func test_disableExactOnAttributes() {
        let query1 = Query()
        XCTAssertNil(query1.disableExactOnAttributes)
        query1.disableExactOnAttributes = ["foo", "bar"]
        XCTAssertEqual(query1.disableExactOnAttributes!, ["foo", "bar"])
        XCTAssertEqual(query1["disableExactOnAttributes"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.disableExactOnAttributes!, ["foo", "bar"])
    }
    
    func test_exactOnSingleWordQuery() {
        let query1 = Query()
        XCTAssertNil(query1.exactOnSingleWordQuery)
        
        let ALL_VALUES: [Query.ExactOnSingleWordQuery] = [.none, .word, .attribute]
        for value in ALL_VALUES {
            query1.exactOnSingleWordQuery = value
            XCTAssertEqual(query1.exactOnSingleWordQuery, value)
            XCTAssertEqual(query1["exactOnSingleWordQuery"], value.rawValue)
            let query2 = Query.parse(query1.build())
            XCTAssertEqual(query2.exactOnSingleWordQuery, value)
            
            XCTAssertEqual(query1.exactOnSingleWordQuery, value)
            XCTAssertEqual(query1["exactOnSingleWordQuery"], value.rawValue)
        }
        
        query1["exactOnSingleWordQuery"] = "invalid"
        XCTAssertNil(query1.exactOnSingleWordQuery)
    }
    
    func test_alternativesAsExact() {
        let query1 = Query()
        XCTAssertNil(query1.alternativesAsExact)

        let VALUES: [Query.AlternativesAsExact] = [.ignorePlurals, .singleWordSynonym, .multiWordsSynonym]
        let RAW_VALUES = ["ignorePlurals", "singleWordSynonym", "multiWordsSynonym"]
        query1.alternativesAsExact = VALUES
        XCTAssertEqual(query1.alternativesAsExact!, VALUES)
        XCTAssertEqual(query1["alternativesAsExact"], RAW_VALUES.joined(separator: ","))
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.alternativesAsExact!, VALUES)
        
        // WARNING: There's a catch: since this parameter is an array, invalid values are just filtered out.
        query1["alternativesAsExact"] = "invalid"
        XCTAssertNotNil(query1.alternativesAsExact)
        XCTAssertEqual(0, query1.alternativesAsExact?.count)
    }
    
    func test_responseFields() {
        let query1 = Query()
        XCTAssertNil(query1.responseFields)
        query1.responseFields = ["foo", "bar"]
        XCTAssertEqual(query1.responseFields!, ["foo", "bar"])
        XCTAssertEqual(query1["responseFields"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.responseFields!, ["foo", "bar"])
    }
    
    func test_facetingAfterDistinct() {
        let query1 = Query()
        XCTAssertNil(query1.facetingAfterDistinct)
        query1.facetingAfterDistinct = true
        XCTAssertEqual(query1.facetingAfterDistinct, true)
        XCTAssertEqual(query1["facetingAfterDistinct"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.facetingAfterDistinct, true)
    }

    func test_maxFacetHits() {
        let query1 = Query()
        XCTAssertNil(query1.maxFacetHits)
        query1.maxFacetHits = 66
        XCTAssertEqual(query1.maxFacetHits, 66)
        XCTAssertEqual(query1["maxFacetHits"], "66")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.maxFacetHits, query1.maxFacetHits)
    }

    func test_percentileComputation() {
        let query1 = Query()
        XCTAssertNil(query1.percentileComputation)
        query1.percentileComputation = false
        XCTAssertEqual(query1.percentileComputation, false)
        XCTAssertEqual(query1["percentileComputation"], "false")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.percentileComputation, false)
    }
}
