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
import Foundation
import XCTest


class OfflineIndexTests: OfflineTestCase {

    func testSaveGetDeleteObject() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        index.beginTransaction()
        index.saveObject(objects["snoopy"]!) { (content, error) in
            guard let content = content else { XCTFail(); return }
            XCTAssertNotNil(content["updatedAt"] as? String)
            guard let objectID = content["objectID"] as? String else { XCTFail(); return }
            XCTAssertEqual("1", objectID)
            index.commitTransaction() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.getObject(withID: "1") { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let name = content["name"] as? String else { XCTFail(); return }
                    XCTAssertEqual(name, "Snoopy")
                    index.beginTransaction()
                    index.deleteObject(withID: "1") { (content, error) in
                        guard let content = content else { XCTFail(); return }
                        XCTAssertNotNil(content["deletedAt"] as? String)
                        index.commitTransaction() { (content, error) in
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
                index.beginTransaction()
                try index.saveObjectSync(self.objects["snoopy"]!)
                try index.commitTransactionSync()
                index.getObject(withID: "1") { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let name = content["name"] as? String else { XCTFail(); return }
                    XCTAssertEqual(name, "Snoopy")
                    queue.async {
                        do {
                            index.beginTransaction()
                            try index.deleteObjectSync(withID: "1")
                            try index.commitTransactionSync()
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
        index.beginTransaction()
        index.saveObjects(Array(objects.values)) { (content, error) in
            guard let content = content else { XCTFail(); return }
            XCTAssertNotNil(content["objectIDs"] as? [AnyObject])
            index.commitTransaction() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.getObjects(withIDs: ["1", "2"]) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let items = content["results"] as? [[String: AnyObject]] else { XCTFail(); return }
                    XCTAssertEqual(items.count, 2)
                    XCTAssertEqual(items[0]["name"] as! String, "Snoopy")
                    index.beginTransaction()
                    index.deleteObjects(withIDs: ["1", "2"]) { (content, error) in
                        guard let content = content else { XCTFail(); return }
                        XCTAssertNotNil(content["objectIDs"] as? [AnyObject])
                        index.commitTransaction() { (content, error) in
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
                index.beginTransaction()
                try index.saveObjectsSync(Array(self.objects.values))
                try index.commitTransactionSync()
                index.getObjects(withIDs: ["1", "2"]) { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    guard let items = content["results"] as? [[String: AnyObject]] else { XCTFail(); return }
                    XCTAssertEqual(items.count, 2)
                    XCTAssertEqual(items[0]["name"] as! String, "Snoopy")
                    queue.async {
                        do {
                            index.beginTransaction()
                            try index.deleteObjectsSync(withIDs: ["1", "2"])
                            try index.commitTransactionSync()
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
        index.beginTransaction()
        index.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            index.commitTransaction() { (content, error) in
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
        index.beginTransaction()
        index.setSettings(settings) { (content, error) in
            XCTAssertNil(error)
            index.commitTransaction() { (content, error) in
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
                index.beginTransaction()
                try index.setSettingsSync(settings)
                try index.commitTransactionSync()
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
        index.beginTransaction()
        index.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            index.commitTransaction() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.beginTransaction()
                index.clearIndex() { (content, error) in
                    guard let content = content else { XCTFail(); return }
                    XCTAssertNotNil(content["updatedAt"] as? String)
                    index.commitTransaction() { (content, error) in
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
                index.beginTransaction()
                try index.saveObjectsSync(Array(self.objects.values))
                try index.commitTransactionSync()

                index.beginTransaction()
                try index.clearIndexSync()
                try index.commitTransactionSync()

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
        index.beginTransaction()
        index.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            index.commitTransaction() { (content, error) in
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
        index.beginTransaction()
        index.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            index.commitTransaction() { (content, error) in
                guard error == nil else { XCTFail(); return }
                index.beginTransaction()
                index.deleteByQuery(Query(parameters: ["numericFilters": "born < 1970"])) { (content, error) in
                    XCTAssertNil(error)
                    index.commitTransaction() { (content, error) in
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
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }
    
    func testMultipleQueries() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        index.beginTransaction()
        index.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            index.commitTransaction() { (content, error) in
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
                index.beginTransaction()
                try index.saveObjectsSync(Array(self.objects.values))
                try index.rollbackTransactionSync()
                XCTAssertFalse(self.client.hasOfflineData(indexName: #function))
                
                index.beginTransaction()
                try index.saveObjectSync(self.objects["snoopy"]!)
                try index.commitTransactionSync()
                XCTAssertTrue(self.client.hasOfflineData(indexName: #function))

                index.beginTransaction()
                try index.saveObjectSync(self.objects["woodstock"]!)
                try index.rollbackTransactionSync()

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
}
