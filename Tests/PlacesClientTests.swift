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


class PlacesClientTests: XCTestCase {
    let expectationTimeout: TimeInterval = 100

    var places: PlacesClient!
    
    override func setUp() {
        super.setUp()
        
        // Init client.
        let appID = ProcessInfo.processInfo.environment["PLACES_APPLICATION_ID"] ?? PLACES_APP_ID
        let apiKey = ProcessInfo.processInfo.environment["PLACES_API_KEY"] ?? PLACES_API_KEY
        places = PlacesClient(appID: appID, apiKey: apiKey)
    }
    
    func testSearch() {
        let expectation = self.expectation(description: #function)
        let query = PlacesQuery()
        query.query = "Paris"
        query.type = .city
        query.hitsPerPage = 10
        query.aroundLatLngViaIP = false
        query.aroundLatLng = LatLng(lat: 32.7767, lng: -96.7970) // Dallas, TX, USA
        query.language = "en"
        query.countries = ["fr", "us"]
        places.search(query) { (content, error) in
            XCTAssert(content != nil)
            XCTAssertNotNil(content?["hits"] as? [JSONObject])
            XCTAssertFalse((content!["hits"] as! [JSONObject]).isEmpty)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
}
