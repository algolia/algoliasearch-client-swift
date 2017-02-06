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

import AlgoliaSearchOffline
import Foundation
import XCTest


class OfflineIndexTests: OfflineTestCase {

    func testSaveGetDeleteObject() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction1 = index.newTransaction()
        transaction1.saveObject(objects["snoopy"]!) { (content, error) in
            guard let content = content else { XCTFail(); return }
            guard let objectID = content["objectID"] as? String else { XCTFail(); return }
            XCTAssertEqual("1", objectID)
            transaction1.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.getObject(withID: "1") { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let name = content["name"] as? String else { XCTFail(); return }
                    XCTAssertEqual(name, "Snoopy")
                    let transaction2 = index.newTransaction()
                    transaction2.deleteObjects(withIDs: ["1"]) { (content, error) in
                        guard content != nil else { XCTFail(); return }
                        transaction2.commit() { (content, error) in
                            guard error == nil else { XCTFail(); return }
                            index.getObject(withID: "1") { (content, error) in
                                XCTAssertNotNil(error)
                                guard let error = error as? HTTPError else { XCTFail("Error not of the right type"); return }
                                XCTAssertEqual(error.statusCode, 404)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }

    func testSaveGetDeleteObjectSync() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let queue = DispatchQueue(label: #function)
        queue.async {
            do {
                let transaction1 = index.newTransaction()
                try transaction1.saveObjectSync(self.objects["snoopy"]!)
                try transaction1.commitSync()
                index.getObject(withID: "1") { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let name = content["name"] as? String else { XCTFail(); return }
                    XCTAssertEqual(name, "Snoopy")
                    queue.async {
                        do {
                            let transaction2 = index.newTransaction()
                            try transaction2.deleteObjectsSync(withIDs: ["1"])
                            try transaction2.commitSync()
                            index.getObject(withID: "1") { (content, error) in
                                XCTAssertNotNil(error)
                                guard let error = error as? HTTPError else { XCTFail("Error not of the right type"); return }
                                XCTAssertEqual(error.statusCode, 404)
                                expectation.fulfill()
                            }
                        } catch let e {
                            XCTFail(e.localizedDescription)
                            expectation.fulfill()
                        }
                    }
                }
            } catch let e {
                XCTFail(e.localizedDescription)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testSaveGetDeleteObjects() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction1 = index.newTransaction()
        transaction1.saveObjects(Array(objects.values)) { (content, error) in
            guard let content = content else { XCTFail(); return }
            XCTAssertNotNil(content["objectIDs"] as? [AnyObject])
            transaction1.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.getObjects(withIDs: ["1", "2"]) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let items = content["results"] as? [[String: AnyObject]] else { XCTFail(); return }
                    XCTAssertEqual(items.count, 2)
                    XCTAssertEqual(items[0]["name"] as! String, "Snoopy")
                    let transaction2 = index.newTransaction()
                    transaction2.deleteObjects(withIDs: ["1", "2"]) { (content, error) in
                        guard let content = content else { XCTFail(); return }
                        XCTAssertNotNil(content["objectIDs"] as? [AnyObject])
                        transaction2.commit() { (content, error) in
                            guard error == nil else { XCTFail(); return }
                            index.getObject(withID: "2") { (content, error) in
                                XCTAssertNotNil(error)
                                guard let error = error as? HTTPError else { XCTFail("Error not of the right type"); return }
                                XCTAssertEqual(error.statusCode, 404)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }

    func testSaveGetDeleteObjectsSync() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let queue = DispatchQueue(label: #function)
        queue.async {
            do {
                let transaction1 = index.newTransaction()
                try transaction1.saveObjectsSync(Array(self.objects.values))
                try transaction1.commitSync()
                index.getObjects(withIDs: ["1", "2"]) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let items = content["results"] as? [[String: AnyObject]] else { XCTFail(); return }
                    XCTAssertEqual(items.count, 2)
                    XCTAssertEqual(items[0]["name"] as! String, "Snoopy")
                    queue.async {
                        do {
                            let transaction2 = index.newTransaction()
                            try transaction2.deleteObjectsSync(withIDs: ["1", "2"])
                            try transaction2.commitSync()
                            index.getObject(withID: "2") { (content, error) in
                                XCTAssertNotNil(error)
                                guard let error = error as? HTTPError else { XCTFail("Error not of the right type"); return }
                                XCTAssertEqual(error.statusCode, 404)
                                expectation.fulfill()
                            }
                        } catch let e {
                            XCTFail(e.localizedDescription)
                            expectation.fulfill()
                        }
                    }
                }
            } catch let e {
                XCTFail(e.localizedDescription)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testSearch() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction = index.newTransaction()
        transaction.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            transaction.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                let query = Query(query: "snoopy")
                index.search(query) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let nbHits = content["nbHits"] as? Int else { XCTFail(); return }
                    XCTAssertEqual(nbHits, 1)
                    guard let hits = content["hits"] as? [[String: AnyObject]] else { XCTFail(); return }
                    XCTAssertEqual(hits.count, 1)
                    guard let name = hits[0]["name"] as? String else { XCTFail(); return }
                    XCTAssertEqual(name, "Snoopy")
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }
    
    func testGetSetSettings() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let settings: JSONObject = [
            "attributesToIndex": ["foo", "bar"]
        ]
        let transaction = index.newTransaction()
        transaction.setSettings(settings) { (content, error) in
            XCTAssertNil(error)
            transaction.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.getSettings() { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    XCTAssertEqual(content["attributesToIndex"] as! NSObject, settings["attributesToIndex"] as! NSObject)
                    XCTAssert(content["attributesToRetrieve"] as! NSObject == NSNull())
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }

    func testGetSetSettingsSync() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let queue = DispatchQueue(label: #function)
        let settings: JSONObject = [
            "attributesToIndex": ["foo", "bar"]
        ]
        queue.async {
            do {
                let transaction = index.newTransaction()
                try transaction.setSettingsSync(settings)
                try transaction.commitSync()
                index.getSettings() { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    XCTAssertEqual(content["attributesToIndex"] as! NSObject, settings["attributesToIndex"] as! NSObject)
                    XCTAssert(content["attributesToRetrieve"] as! NSObject == NSNull())
                    expectation.fulfill()
                }
            } catch let e {
                XCTFail(e.localizedDescription)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testClear() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction1 = index.newTransaction()
        transaction1.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            transaction1.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                let transaction2 = index.newTransaction()
                transaction2.clearIndex() { (content, error) in
                    guard content != nil else { XCTFail(); return }
                    transaction2.commit() { (content, error) in
                        guard error == nil else { XCTFail(); return }
                        index.browse(query: Query()) { (content, error) in
                            guard let content = content else { XCTFail(); return }
                            guard let nbHits = content["nbHits"] as? Int else { XCTFail(); return }
                            XCTAssertEqual(nbHits, 0)
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }

    func testClearSync() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let queue = DispatchQueue(label: #function)
        queue.async {
            do {
                let transaction1 = index.newTransaction()
                try transaction1.saveObjectsSync(Array(self.objects.values))
                try transaction1.commitSync()

                let transaction2 = index.newTransaction()
                try transaction2.clearIndexSync()
                try transaction2.commitSync()

                index.browse(query: Query()) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let nbHits = content["nbHits"] as? Int else { XCTFail(); return }
                    XCTAssertEqual(nbHits, 0)
                    expectation.fulfill()
                }
            } catch let e {
                XCTFail(e.localizedDescription)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testBrowse() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction = index.newTransaction()
        transaction.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            transaction.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.browse(query: Query(parameters: ["hitsPerPage": "1"])) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let cursor = content["cursor"] as? String else { XCTFail(); return }
                    index.browseFrom(cursor: cursor) { (content, error) in
                        guard let content = content else { XCTFail(); return }
                        XCTAssertNil(content["cursor"])
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }
    
    func testDeleteByQuery() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction1 = index.newTransaction()
        transaction1.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            transaction1.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.deleteByQuery(Query(parameters: ["numericFilters": "born < 1970"])) { (content, error) in
                    guard error == nil else { XCTFail(); return }
                    index.browse(query: Query()) { (content, error) in
                        guard let content = content else { XCTFail(); return }
                        guard let nbHits = content["nbHits"] as? Int else { XCTFail(); return }
                        XCTAssertEqual(nbHits, 1)
                        XCTAssertNil(content["cursor"])
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1000 * expectationTimeout, handler: nil)
    }
    
    func testMultipleQueries() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction = index.newTransaction()
        transaction.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            transaction.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.multipleQueries([Query(query: "snoopy"), Query(query: "woodstock")]) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let results = content["results"] as? [[String: AnyObject]] else { XCTFail(); return }
                    XCTAssertEqual(results.count, 2)
                    for result in results {
                        guard let nbHits = result["nbHits"] as? Int else { XCTFail(); return }
                        XCTAssertEqual(nbHits, 1)
                    }
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }
    
    func testRollback() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let queue = DispatchQueue(label: #function)
        queue.async {
            do {
                let transaction1 = index.newTransaction()
                try transaction1.saveObjectsSync(Array(self.objects.values))
                transaction1.rollbackSync()
                XCTAssertFalse(self.client.hasOfflineData(indexName: #function))
                
                let transaction2 = index.newTransaction()
                try transaction2.saveObjectSync(self.objects["snoopy"]!)
                try transaction2.commitSync()
                XCTAssertTrue(self.client.hasOfflineData(indexName: #function))

                let transaction3 = index.newTransaction()
                try transaction3.saveObjectSync(self.objects["woodstock"]!)
                transaction3.rollbackSync()

                index.browse(query: Query()) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let nbHits = content["nbHits"] as? Int else { XCTFail(); return }
                    XCTAssertEqual(nbHits, 1)
                    XCTAssertNil(content["cursor"])
                    expectation.fulfill()
                }
            } catch let e {
                XCTFail(e.localizedDescription)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    /// Test that we can chain async write operations without waiting for the handler to be called, and that it
    /// still works.
    func testAsyncUpdatesInParallel() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction = index.newTransaction()
        transaction.clearIndex()
        transaction.saveObject(self.objects["snoopy"]!)
        transaction.saveObject(self.objects["woodstock"]!)
        transaction.deleteObjects(withIDs: ["1"])
        transaction.setSettings([:])
        transaction.commit() { (content, error) in
            XCTAssertNil(error)
            index.browse(query: Query()) { (content, error) in
                guard let content = content else { XCTFail(); return }
                guard let nbHits = content["nbHits"] as? Int else { XCTFail(); return }
                XCTAssertEqual(nbHits, 1)
                XCTAssertNil(content["cursor"])
                guard let hits = content["hits"] as? [JSONObject] else { XCTFail(); return }
                XCTAssertEqual(hits[0]["name"] as? String, "Woodstock")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testBuild() {
        let expectation = self.expectation(description: #function)
        
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
        let index = client.offlineIndex(withName: #function)
        
        // Check that no offline data exists.
        XCTAssertFalse(index.hasOfflineData)
        
        // Build the index.
        index.build(settingsFile: settingsFile, objectFiles: [objectFile]) {
            (content, error) in
            XCTAssertNil(error)
            
            // Check that offline data exists now.
            XCTAssertTrue(index.hasOfflineData)
            
            // Search.
            let query = Query()
            query.query = "peanuts"
            query.filters = "kind:animal"
            index.search(query) {
                (content, error) in
                XCTAssertNil(error)
                XCTAssertEqual(content?["nbHits"] as? Int, 2)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testSearchForFacetValues() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction = index.newTransaction()
        transaction.setSettings(settings) { (content, error) in
            XCTAssertNil(error)
            transaction.saveObjects(Array(self.objects.values)) { (content, error) in
                XCTAssertNil(error)
                transaction.commit() { (content, error) in
                    guard error == nil else { XCTFail(); return }
                    let query = Query(query: "snoopy")
                    index.searchForFacetValues(of: "series", matching: "pea", query: query) { (content, error) in
                        guard let content = content else { XCTFail(); return }
                        guard let facetHits = content["facetHits"] as? [JSONObject] else { XCTFail(); return }
                        XCTAssertEqual(1, facetHits.count)
                        XCTAssertEqual("Peanuts", facetHits[0]["value"] as? String)
                        XCTAssertEqual(1, facetHits[0]["count"] as? Int)
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }
}
