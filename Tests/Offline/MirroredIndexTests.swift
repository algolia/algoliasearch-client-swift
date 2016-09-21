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

import AlgoliaSearch
import XCTest


class MirroredIndexTests: OfflineTestCase {
    
    /// Higher timeout for online queries.
    let onlineExpectationTimeout: TimeInterval = 30.0
    
    let moreObjects: [String: JSONObject] = [
        "snoopy": [
            "objectID": "1",
            "name": "Snoopy",
            "kind": [ "dog", "animal" ],
            "born": 1967,
            "series": "Peanuts"
        ],
        "woodstock": [
            "objectID": "2",
            "name": "Woodstock",
            "kind": ["bird", "animal" ],
            "born": 1970,
            "series": "Peanuts"
        ],
        "charlie": [
            "objectID": "3",
            "name": "Charlie Brown",
            "kind": [ "human" ],
            "born": 1950,
            "series": "Peanuts"
        ],
        "hobbes": [
            "objectID": "4",
            "name": "Hobbes",
            "kind": [ "tiger", "animal", "teddy" ],
            "born": 1985,
            "series": "Calvin & Hobbes"
        ],
        "calvin": [
            "objectID": "5",
            "name": "Calvin",
            "kind": [ "human" ],
            "born": 1985,
            "series": "Calvin & Hobbes"
        ]
    ]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// Test synchronization.
    ///
    /// + Note: Because it is painful to populate and sync the index, we test many things in this test case.
    ///
    func testSync() {
        let expectation_indexing = self.expectation(description: "indexing")
        let expectation_onlineQuery = self.expectation(description: "onlineQuery")
        let expectation_offlineQuery = self.expectation(description: "offlineQuery")
        let expectation_mixedQuery = self.expectation(description: "offlineQuery")
        
        // Populate the online index.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        index.addObjects(Array(moreObjects.values)) { (content, error) in
            guard let taskID = content?["taskID"] as? Int else { XCTFail(); return }
            index.waitTask(withID: taskID) { (content, error) in
                XCTAssertNil(error)
                
                // Sync the index.
                index.mirrored = true
                let query = Query()
                query.numericFilters = ["born < 1980"]
                index.dataSelectionQueries = [
                    DataSelectionQuery(query: query, maxObjects: 10)
                ]
                NotificationCenter.default.addObserver(forName: MirroredIndex.SyncDidFinishNotification, object: index, queue: OperationQueue.main) { (notification) in
                    if let error = notification.userInfo?[MirroredIndex.syncErrorKey] as? Error { XCTFail("\(error)"); return }

                    // Query the online index explicitly.
                    index.searchOnline(Query()) { (content, error) in
                        XCTAssertNil(error)
                        XCTAssertEqual(5, content?["nbHits"] as? Int)
                        XCTAssertEqual("remote", content?["origin"] as? String)
                        expectation_onlineQuery.fulfill()
                    }
                    
                    // Query the offline index explicitly.
                    index.searchOffline(Query()) { (content, error) in
                        XCTAssertNil(error)
                        XCTAssertEqual(3, content?["nbHits"] as? Int)
                        XCTAssertEqual("local", content?["origin"] as? String)
                        expectation_offlineQuery.fulfill()
                    }
                    
                    // Test offline fallback.
                    self.client.readHosts = [ "unknown.algolia.com" ]
                    index.requestStrategy = .fallbackOnFailure
                    index.search(Query()) { (content, error) in
                        XCTAssertNil(error)
                        XCTAssertEqual(3, content?["nbHits"] as? Int)
                        XCTAssertEqual("local", content?["origin"] as? String)
                        expectation_mixedQuery.fulfill()
                    }
                    
                    expectation_indexing.fulfill()
                }
                index.sync()
            }
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }
}
