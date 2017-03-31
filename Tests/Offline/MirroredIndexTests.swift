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

@testable import AlgoliaSearchOffline
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
    
    private func populate(index: MirroredIndex, completionBlock: @escaping (Error?) -> Void) {
        // Delete the index.
        client.deleteIndex(withName: index.name) { (content, error) -> Void in
            XCTAssertNil(error)
            if error != nil {
                completionBlock(error)
                return
            }
            // Populate the online index.
            index.setSettings(self.settings) { (content, error) in
                XCTAssertNil(error)
                index.addObjects(Array(self.moreObjects.values)) { (content, error) in
                    guard let taskID = content?["taskID"] as? Int else { XCTFail(); return }
                    index.waitTask(withID: taskID) { (content, error) in
                        XCTAssertNil(error)
                        completionBlock(error)
                    }
                }
            }
        }
    }
    
    private func sync(index: MirroredIndex, completionBlock: @escaping (Error?) -> Void) {
        populate(index:  index) { (error) -> Void in
            XCTAssertNil(error)
            if error != nil {
                completionBlock(error)
                return
            }

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
                let error = notification.userInfo?[MirroredIndex.errorKey] as? Error
                completionBlock(error)
            }
            index.sync()
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
                    let error = notification.userInfo?[MirroredIndex.errorKey] as? Error
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
        }
        index.buildOffline(settingsFile: settingsFile, objectFiles: [objectFile]) {
            (content, error) in
            XCTAssertNil(error)
            
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
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetObject() {
        let expectation_indexing = self.expectation(description: "indexing")
        let expectation_onlineQuery = self.expectation(description: "onlineQuery")
        let expectation_offlineQuery = self.expectation(description: "offlineQuery")
        let expectation_mixedQuery = self.expectation(description: "offlineQuery")
        
        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }
            
            // Query the online index explicitly.
            index.getObjectOnline(withID: "1") { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual("Snoopy", content?["name"] as? String)
                XCTAssertEqual("remote", content?["origin"] as? String)
                expectation_onlineQuery.fulfill()
            }
            
            // Query the offline index explicitly.
            index.getObjectOffline(withID: "2") { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual("Woodstock", content?["name"] as? String)
                XCTAssertEqual("local", content?["origin"] as? String)
                expectation_offlineQuery.fulfill()
            }
            
            // Test offline fallback.
            self.client.readHosts = [ "unknown.algolia.com" ]
            index.requestStrategy = .fallbackOnFailure
            index.getObject(withID: "3") { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual("Charlie Brown", content?["name"] as? String)
                XCTAssertEqual("local", content?["origin"] as? String)
                expectation_mixedQuery.fulfill()
            }
            
            expectation_indexing.fulfill()
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }

    func testGetObjects() {
        let expectation_indexing = self.expectation(description: "indexing")
        let expectation_onlineQuery = self.expectation(description: "onlineQuery")
        let expectation_offlineQuery = self.expectation(description: "offlineQuery")
        let expectation_mixedQuery = self.expectation(description: "offlineQuery")
        
        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }
            
            // Query the online index explicitly.
            index.getObjectsOnline(withIDs: ["1"]) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(1, (content?["results"] as? [JSONObject])?.count)
                XCTAssertEqual("remote", content?["origin"] as? String)
                expectation_onlineQuery.fulfill()
            }
            
            // Query the offline index explicitly.
            index.getObjectsOffline(withIDs: ["1", "2"]) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(2, (content?["results"] as? [JSONObject])?.count)
                XCTAssertEqual("local", content?["origin"] as? String)
                expectation_offlineQuery.fulfill()
            }
            
            // Test offline fallback.
            self.client.readHosts = [ "unknown.algolia.com" ]
            index.requestStrategy = .fallbackOnFailure
            index.getObjects(withIDs: ["1", "2", "3"]) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(3, (content?["results"] as? [JSONObject])?.count)
                XCTAssertEqual("local", content?["origin"] as? String)
                expectation_mixedQuery.fulfill()
            }
            
            expectation_indexing.fulfill()
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }

    /// Test the `onlineOnly` request strategy.
    ///
    func testRequestStrategyOnlineOnly() {
        let expectation = self.expectation(description: #function)

        // Mock reachability.
        let reachability = MockNetworkReachability()
        client.reachability = reachability

        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        index.requestStrategy = .onlineOnly
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }

            // Test success.
            index.search(Query()) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(5, content?["nbHits"] as? Int)
                XCTAssertEqual("remote", content?["origin"] as? String)

                // Test that reachability is observed.
                reachability.reachable = false
                let startTime = Date()
                index.search(Query()) { (content, error) in
                    let stopTime = Date()
                    let duration = stopTime.timeIntervalSince(startTime)
                    guard let error = error as NSError? else { XCTFail("Request should have failed"); expectation.fulfill(); return }
                    XCTAssertEqual(NSURLErrorDomain, error.domain)
                    XCTAssertEqual(NSURLErrorNotConnectedToInternet, error.code)
                    XCTAssert(duration < min(self.client.searchTimeout, self.client.timeout)) // check that we failed without waiting for the timeout
                
                    // Test real network failure.
                    reachability.reachable = true
                    self.client.readHosts = [ "unknown.algolia.com" ]
                    index.search(Query()) { (content, error) in
                        guard let error = error as NSError? else { XCTFail("Request should have failed"); expectation.fulfill(); return }
                        XCTAssertEqual(NSURLErrorDomain, error.domain)
                        // Check that we failed with something else than a connectivity error caused by reachability.
                        XCTAssertNotEqual(NSURLErrorNotConnectedToInternet, error.code)

                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }

    /// Test the `offlineOnly` request strategy.
    ///
    func testRequestStrategyOfflineOnly() {
        let expectation = self.expectation(description: #function)

        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        index.mirrored = true
        index.requestStrategy = .offlineOnly

        // Check that a request without local data fails.
        index.search(Query()) { (content, error) in
            XCTAssertNotNil(error)

            // Populate the online index & sync the offline mirror.
            self.sync(index: index) { (error) in
                if let error = error { XCTFail("\(error)"); expectation.fulfill(); return }
                
                // Test success.
                index.search(Query()) { (content, error) in
                    XCTAssertNil(error)
                    XCTAssertEqual(3, content?["nbHits"] as? Int)
                    XCTAssertEqual("local", content?["origin"] as? String)
                    
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }
    
    /// Test the `fallbackOnFailure` request strategy.
    ///
    func testRequestStrategyFallbackOnFailure() {
        let expectation = self.expectation(description: #function)

        // Mock reachability.
        let reachability = MockNetworkReachability()
        client.reachability = reachability
        
        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        index.requestStrategy = .fallbackOnFailure
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }
            
            // Test success.
            index.search(Query()) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(5, content?["nbHits"] as? Int)
                XCTAssertEqual("remote", content?["origin"] as? String)
                
                // Test that reachability is observed.
                reachability.reachable = false
                index.search(Query()) { (content, error) in
                    XCTAssertNil(error)
                    XCTAssertEqual(3, content?["nbHits"] as? Int)
                    XCTAssertEqual("local", content?["origin"] as? String)
                    
                    // Test real network failure.
                    reachability.reachable = true
                    self.client.readHosts = [ "unknown.algolia.com" ]
                    index.search(Query()) { (content, error) in
                        XCTAssertNil(error)
                        XCTAssertEqual(3, content?["nbHits"] as? Int)
                        XCTAssertEqual("local", content?["origin"] as? String)
                        
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }

    /// Test the `fallbackOnTimeout` request strategy.
    ///
    func testRequestStrategyFallbackOnTimeout() {
        let expectation = self.expectation(description: #function)
        
        // Mock reachability.
        let reachability = MockNetworkReachability()
        client.reachability = reachability
        
        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        index.requestStrategy = .fallbackOnTimeout
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }
            
            // Test success.
            index.search(Query()) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(5, content?["nbHits"] as? Int)
                XCTAssertEqual("remote", content?["origin"] as? String)
                
                // Test that reachability is observed.
                reachability.reachable = false
                index.search(Query()) { (content, error) in
                    XCTAssertNil(error)
                    XCTAssertEqual(3, content?["nbHits"] as? Int)
                    XCTAssertEqual("local", content?["origin"] as? String)
                    
                    // Test real network failure.
                    reachability.reachable = true
                    self.client.readHosts = [ uniqueAlgoliaBizHost() ]
                    let startTime = Date()
                    index.search(Query()) { (content, error) in
                        let stopTime = Date()
                        let duration = stopTime.timeIntervalSince(startTime)
                        XCTAssertNil(error)
                        XCTAssertEqual(3, content?["nbHits"] as? Int)
                        XCTAssertEqual("local", content?["origin"] as? String)
                        // Check that we hit the fallback time out, but not the complete online timeout.
                        XCTAssert(duration >= index.offlineFallbackTimeout)
                        XCTAssert(duration < min(self.client.searchTimeout, self.client.timeout))
                        
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }
    
    /// Test that a non-mirrored index behaves like a purely online index.
    ///
    func testNotMirrored() {
        let expectation_populate = self.expectation(description: #function + " (populate)")
        let expectation_search = self.expectation(description: #function + " (search)")
        let expectation_browse = self.expectation(description: #function + " (browse)")
        let expectation_get_object = self.expectation(description: #function + " (get object)")
        let expectation_get_objects = self.expectation(description: #function + " (get objects)")
        
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        // Check that the index is *not* mirrored by default.
        XCTAssertFalse(index.mirrored)

        populate(index: index) { (error) in
            // Check that a non-mirrored index returns online results without origin tagging.
            index.search(Query()) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(5, content?["nbHits"] as? Int)
                XCTAssertNil(content?["origin"])
                expectation_search.fulfill()
            }
            index.browse(query: Query()) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(5, content?["nbHits"] as? Int)
                XCTAssertNil(content?["origin"])
                expectation_browse.fulfill()
            }
            index.getObject(withID: "1") { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual("Snoopy", content?["name"] as? String)
                XCTAssertNil(content?["origin"])
                expectation_get_object.fulfill()
            }
            index.getObjects(withIDs: ["1", "2"]) { (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(2, (content?["results"] as? [JSONObject])?.count)
                XCTAssertNil(content?["origin"])
                expectation_get_objects.fulfill()
            }
            expectation_populate.fulfill()
        }
        
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }
    
    /// Test that we can switch an index from not mirrored to mirrored and back without causing any harm.
    ///
    /// + Bug: [#285](https://github.com/algolia/algoliasearch-client-swift/issues/285).
    ///
    func testMirroredSetUnset() {
        let expectation_property = self.expectation(description: #function + " (property)")
        let expectation_search = self.expectation(description: #function + " (search)")

        let index: MirroredIndex = client.index(withName: safeIndexName(#function))

        // NOTE: We don't care about the search results here. We are just interested in not crashing.
        //
        let propertyQueue = DispatchQueue(label: "Property queue")
        let OUTER_ITERATIONS = 100
        let INNER_ITERATIONS = 100
        var completedProperties = 0
        var completedSearches = 0
        for _ in 1...OUTER_ITERATIONS {
            propertyQueue.async {
                for i in 1...INNER_ITERATIONS {
                    index.mirrored = i % 2 == 1
                }
                completedProperties += 1
                if completedProperties == OUTER_ITERATIONS {
                    expectation_property.fulfill()
                }
            }
            for _ in 1...1 {
                index.search(Query()) { (content, error) in
                    completedSearches += 1
                    if completedSearches == OUTER_ITERATIONS {
                        expectation_search.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }

    func testSearchForFacetValues() {
        let expectation_indexing = self.expectation(description: "indexing")
        let expectation_onlineQuery = self.expectation(description: "onlineQuery")
        let expectation_offlineQuery = self.expectation(description: "offlineQuery")
        let expectation_mixedQuery = self.expectation(description: "offlineQuery")
        
        // Populate the online index & sync the offline mirror.
        let index: MirroredIndex = client.index(withName: safeIndexName(#function))
        sync(index: index) { (error) in
            if let error = error { XCTFail("\(error)"); return }
            
            // Query the online index explicitly.
            index.searchForFacetValuesOnline(of: "series", matching: "") { (content, error) in
                XCTAssertNil(error)
                guard let facetHits = content?["facetHits"] as? [JSONObject] else { XCTFail(); return }
                XCTAssertEqual(2, facetHits.count)
                XCTAssertEqual("remote", content?["origin"] as? String)
                expectation_onlineQuery.fulfill()
            }
            
            // Query the offline index explicitly.
            index.searchForFacetValuesOffline(of: "series", matching: "") { (content, error) in
                XCTAssertNil(error)
                guard let facetHits = content?["facetHits"] as? [JSONObject] else { XCTFail(); return }
                XCTAssertEqual(1, facetHits.count)
                XCTAssertEqual("Peanuts", facetHits[0]["value"] as? String)
                XCTAssertEqual(3, facetHits[0]["count"] as? Int)
                XCTAssertEqual("local", content?["origin"] as? String)
                expectation_offlineQuery.fulfill()
            }
            
            // Test offline fallback.
            self.client.readHosts = [ "unknown.algolia.com" ]
            index.requestStrategy = .fallbackOnFailure
            let query = Query()
            query.query = "snoopy"
            index.searchForFacetValues(of: "series", matching: "pea", query: query) { (content, error) in
                XCTAssertNil(error)
                guard let facetHits = content?["facetHits"] as? [JSONObject] else { XCTFail(); return }
                XCTAssertEqual(1, facetHits.count)
                XCTAssertEqual("Peanuts", facetHits[0]["value"] as? String)
                XCTAssertEqual(1, facetHits[0]["count"] as? Int)
                XCTAssertEqual("local", content?["origin"] as? String)
                expectation_mixedQuery.fulfill()
            }
            
            expectation_indexing.fulfill()
        }
        waitForExpectations(timeout: onlineExpectationTimeout, handler: nil)
    }
}
