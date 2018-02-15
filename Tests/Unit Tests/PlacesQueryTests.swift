//
//  Copyright (c) 2016 Algolia
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

import XCTest
@testable import AlgoliaSearch


class PlacesQueryTests: XCTestCase {

    func test_query() {
        let query1 = PlacesQuery()
        XCTAssertNil(query1.query)
        query1.query = "San Francisco"
        XCTAssertEqual(query1.query, "San Francisco")
        XCTAssertEqual(query1["query"], "San Francisco")
        let query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.query, "San Francisco")
    }

    func test_type() {
        let query1 = PlacesQuery()
        XCTAssertNil(query1.type)
        
        query1.type = .city
        XCTAssertEqual(query1.type, .city)
        XCTAssertEqual(query1["type"], "city")
        var query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.type, .city)

        query1.type = .country
        XCTAssertEqual(query1.type, .country)
        XCTAssertEqual(query1["type"], "country")
        query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.type, .country)

        query1.type = .address
        XCTAssertEqual(query1.type, .address)
        XCTAssertEqual(query1["type"], "address")
        query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.type, .address)

        query1.type = .busStop
        XCTAssertEqual(query1.type, .busStop)
        XCTAssertEqual(query1["type"], "busStop")
        query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.type, .busStop)

        query1.type = .trainStation
        XCTAssertEqual(query1.type, .trainStation)
        XCTAssertEqual(query1["type"], "trainStation")
        query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.type, .trainStation)

        query1.type = .townhall
        XCTAssertEqual(query1.type, .townhall)
        XCTAssertEqual(query1["type"], "townhall")
        query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.type, .townhall)

        query1.type = .airport
        XCTAssertEqual(query1.type, .airport)
        XCTAssertEqual(query1["type"], "airport")
        query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.type, .airport)

        query1["type"] = "invalid"
        XCTAssertNil(query1.type)
    }

    func test_hitsPerPage() {
        let query1 = PlacesQuery()
        XCTAssertNil(query1.hitsPerPage)
        query1.hitsPerPage = 50
        XCTAssertEqual(query1.hitsPerPage, 50)
        XCTAssertEqual(query1["hitsPerPage"], "50")
        let query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.hitsPerPage, 50)
    }

    func test_language() {
        let query1 = PlacesQuery()
        XCTAssertNil(query1.language)
        query1.language = "en"
        XCTAssertEqual(query1.language, "en")
        XCTAssertEqual(query1["language"], "en")
        let query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.language, "en")
    }

    func test_countries() {
        let VALUES: [String] = ["de", "fr", "us"]
        let query1 = PlacesQuery()
        XCTAssertNil(query1.countries)
        query1.countries = VALUES
        XCTAssertEqual(query1.countries!, VALUES)
        XCTAssertEqual(query1["countries"], "[\"de\",\"fr\",\"us\"]")
        let query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.countries!, VALUES)
    }

    func test_aroundLatLng() {
        let query1 = PlacesQuery()
        XCTAssertNil(query1.aroundLatLng)
        query1.aroundLatLng = LatLng(lat: 89.76, lng: -123.45)
        XCTAssertEqual(query1.aroundLatLng!, LatLng(lat: 89.76, lng: -123.45))
        XCTAssertEqual(query1["aroundLatLng"], "89.76,-123.45")
        let query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.aroundLatLng!, LatLng(lat: 89.76, lng: -123.45))
    }
    
    func test_aroundLatLngViaIP() {
        let query1 = PlacesQuery()
        XCTAssertNil(query1.aroundLatLngViaIP)
        query1.aroundLatLngViaIP = true
        XCTAssertEqual(query1.aroundLatLngViaIP, true)
        XCTAssertEqual(query1["aroundLatLngViaIP"], "true")
        let query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.aroundLatLngViaIP, true)
    }
    
    func test_aroundRadius() {
        let query1 = PlacesQuery()
        XCTAssertNil(query1.aroundRadius)
        query1.aroundRadius = .explicit(987)
        XCTAssertEqual(query1.aroundRadius, .explicit(987))
        XCTAssertEqual(query1["aroundRadius"], "987")
        var query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.aroundRadius, .explicit(987))
        
        query1.aroundRadius = .all
        XCTAssertEqual(query1.aroundRadius, .all)
        XCTAssertEqual(query1["aroundRadius"], "all")
        query2 = PlacesQuery.parse(query1.build())
        XCTAssertEqual(query2.aroundRadius, .all)
    }
}
