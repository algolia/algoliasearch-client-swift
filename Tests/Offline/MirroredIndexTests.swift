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
    let onlineExpectationTimeout: TimeInterval = 100.0
    
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
    
    private func sync(index: MirroredIndex, completionBlock: @escaping (Error?) -> Void) {
        // Delete the index.
        client.deleteIndex(withName: index.name) { (content, error) -> Void in
            XCTAssertNil(error)
            // Populate the online index.
            index.addObjects(Array(self.moreObjects.values)) { (content, error) in
                guard let taskID = content?["taskID"] as? Int else { XCTFail(); return }
                index.waitTask(withID: taskID) { (content, error) in
                    XCTAssertNil(error)
                    
                    // Sync the offline mirror.
                    index.mirrored = true
                    let query = Query()
                    query.numericFilters = ["born < 1980"]
                    index.dataSelectionQueries = [
                        DataSelectionQuery(query: query, maxObjects: 10)
                    ]
                    var observer: NSObjectProtocol?
                    observer = NotificationCenter.default.addObserver(forName: MirroredIndex.SyncDidFinishNotification, object: index, queue: OperationQueue.main) { (notification) in
                        NotificationCenter.default.removeObserver(observer!)
                        let error = notification.userInfo?[MirroredIndex.syncErrorKey] as? Error
                        completionBlock(error)
                    }
                    index.sync()
                }
            }
        }
    }
    
    func testSync() {
        let expectation_indexing = self.expectation(description: "indexing")
        let waitTimeout = 5.0
        
        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }
            
            // Check that a call to `syncIfNeeded()` does *not* trigger a new sync.
            var observer: NSObjectProtocol?
            observer = NotificationCenter.default.addObserver(forName: MirroredIndex.SyncDidStartNotification, object: index, queue: OperationQueue.main) { (notification) in
                NotificationCenter.default.removeObserver(observer!)
                XCTFail("The sync should not have been started again")
            }
            index.syncIfNeeded()

            // Wait to leave a chance for the sync to start.
            DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeout) {
                NotificationCenter.default.removeObserver(observer!)
                
                // Check that changing the data selection queries makes a new sync needed.
                index.dataSelectionQueries = [DataSelectionQuery(query: Query(), maxObjects: 6)]
                var observer: NSObjectProtocol?
                observer = NotificationCenter.default.addObserver(forName: MirroredIndex.SyncDidFinishNotification, object: index, queue: OperationQueue.main) { (notification) in
                    NotificationCenter.default.removeObserver(observer!)
                    let error = notification.userInfo?[MirroredIndex.syncErrorKey] as? Error
                    XCTAssertNil(error)
                    expectation_indexing.fulfill()
                }
                index.syncIfNeeded()
            }
        }
        waitForExpectations(timeout: onlineExpectationTimeout * 2 + waitTimeout, handler: nil)
    }
    
    func testSearch() {
        let expectation_indexing = self.expectation(description: "indexing")
        let expectation_onlineQuery = self.expectation(description: "onlineQuery")
        let expectation_offlineQuery = self.expectation(description: "offlineQuery")
        let expectation_mixedQuery = self.expectation(description: "offlineQuery")
        
        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }
            
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
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }

    func testBrowse() {
        let expectation_indexing = self.expectation(description: "indexing")
        let expectation_onlineQuery = self.expectation(description: "onlineQuery")
        let expectation_offlineQuery = self.expectation(description: "offlineQuery")
        
        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }
            
            // Browse the online index explicitly.
            index.browse(query: Query()) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(5, content?["nbHits"] as? Int)
                expectation_onlineQuery.fulfill()
            }
            
            // Browse the offline index explicitly.
            index.browseMirror(query: Query()) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(3, content?["nbHits"] as? Int)
                expectation_offlineQuery.fulfill()
            }
            
            expectation_indexing.fulfill()
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }
    
    func testBuildOffline() {
        let expectation_buildStart = self.expectation(description: "buildStart")
        let expectation_buildFinish = self.expectation(description: "buildFinish")
        let expectation_search = self.expectation(description: "search")

        // Retrieve data files from resources.
        let bundle = Bundle(for: type(of: self))
        guard
            let settingsFile = bundle.path(forResource: "settings", ofType: "json"),
            let objectFile = bundle.path(forResource: "objects", ofType: "json")
            else {
                XCTFail("Cannot find resources")
                return
        }

        // Create the index.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        index.mirrored = true

        // Check that no offline data exists.
        XCTAssertFalse(index.hasOfflineData)

        // Build the index.
        var observer1: NSObjectProtocol?
        observer1 = NotificationCenter.default.addObserver(forName: MirroredIndex.BuildDidStartNotification, object: index, queue: OperationQueue.main) { (notification) in
            // Check that start notification is sent.
            NotificationCenter.default.removeObserver(observer1!)
            expectation_buildStart.fulfill()
        }
        var observer2: NSObjectProtocol?
        observer2 = NotificationCenter.default.addObserver(forName: MirroredIndex.BuildDidFinishNotification, object: index, queue: OperationQueue.main) { (notification) in
            // Check that finish notification is sent.
            NotificationCenter.default.removeObserver(observer2!)
            let error = notification.userInfo?[MirroredIndex.errorKey] as? Error
            XCTAssertNil(error)
            expectation_buildFinish.fulfill()

            // Check that offline data exists now.
            XCTAssertTrue(index.hasOfflineData)

            // Search.
            let query = Query()
            query.query = "peanuts"
            query.filters = "kind:animal"
            index.searchOffline(query) {
                (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(content?["nbHits"] as? Int, 2)
                expectation_search.fulfill()
            }
        }
        index.buildOffline(settingsFile: settingsFile, objectFiles: [objectFile])

        waitForExpectations(timeout: 10, handler: nil)
    }
}
