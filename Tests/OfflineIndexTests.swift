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
#if false
import XCTest // disabled so far
#endif

// ----------------------------------------------------------------------
// WARNING
// ----------------------------------------------------------------------
// Could not find a way to have proper unit tests work for the offline
// mode. Even if we use Cocoapods to draw the dependency on the Offline
// Core, the build fails with a weird error.
// => I am emulating tests in an iOS app so far.
// ----------------------------------------------------------------------


class OfflineIndexTests: OfflineTestCase {
    override init() {
        super.init()
        tests = [
            self.testAddGetDeleteObject,
            self.testAddWithIDGetDeleteObject,
            self.testAddGetDeleteObjects,
            self.testSearch,
            self.testGetSetSettings,
            self.testClear,
            self.testBrowse,
            self.testDeleteByQuery,
            self.testMultipleQueries
        ]
    }

    func testAddGetDeleteObject() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObject(objects["snoopy"]!) { (content, error) in
            guard let content = content else { assert(false); return }
            assert(content["updatedAt"] as? String != nil)
            guard let objectID = content["objectID"] as? String else { assert(false); return }
            assert(objectID == "1")
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                index.getObject("1") { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let name = content["name"] as? String else { assert(false); return }
                    assert(name == "Snoopy")
                    index.beginTransaction()
                    index.deleteObject("1") { (content, error) in
                        guard let content = content else { assert(false); return }
                        assert(content["deletedAt"] as? String != nil)
                        index.commitTransaction() { (content, error) in
                            guard error == nil else { assert(false); return }
                            index.getObject("1") { (content, error) in
                                assert(error != nil)
                                assert(error!.code == 404)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testAddWithIDGetDeleteObject() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObject(["name": "unknown"], withID: "xxx") { (content, error) in
            guard let content = content else { assert(false); return }
            assert(content["updatedAt"] as? String != nil)
            guard let objectID = content["objectID"] as? String else { assert(false); return }
            assert(objectID == "xxx")
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                index.getObject("xxx") { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let name = content["name"] as? String else { assert(false); return }
                    assert(name == "unknown")
                    index.beginTransaction()
                    index.deleteObject("xxx") { (content, error) in
                        guard let content = content else { assert(false); return }
                        assert(content["deletedAt"] as? String != nil)
                        index.commitTransaction() { (content, error) in
                            guard error == nil else { assert(false); return }
                            index.getObject("xxx") { (content, error) in
                                assert(error != nil)
                                assert(error!.code == 404)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testAddGetDeleteObjects() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObjects(Array(objects.values)) { (content, error) in
            guard let content = content else { assert(false); return }
            assert(content["objectIDs"] as? [AnyObject] != nil)
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                index.getObjects(["1", "2"]) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let items = content["results"] as? [[String: AnyObject]] else { assert(false); return }
                    assert(items.count == 2)
                    assert(items[0]["name"] as! String == "Snoopy")
                    index.beginTransaction()
                    index.deleteObjects(["1", "2"]) { (content, error) in
                        guard let content = content else { assert(false); return }
                        assert(content["objectIDs"] as? [AnyObject] != nil)
                        index.commitTransaction() { (content, error) in
                            guard error == nil else { assert(false); return }
                            index.getObject("2") { (content, error) in
                                assert(error != nil)
                                assert(error!.code == 404)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testSearch() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                let query = Query(query: "snoopy")
                index.search(query) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                    assert(nbHits == 1)
                    guard let hits = content["hits"] as? [[String: AnyObject]] else { assert(false); return }
                    assert(hits.count == 1)
                    guard let name = hits[0]["name"] as? String else { assert(false); return }
                    assert(name == "Snoopy")
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testGetSetSettings() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        let settings: [String: AnyObject] = [
            "attributesToIndex": ["foo", "bar"]
        ]
        index.beginTransaction()
        index.setSettings(settings) { (content, error) in
            assert(error == nil)
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                index.getSettings() { (content, error) in
                    guard let content = content else { assert(false); return }
                    assert(content["attributesToIndex"] as! NSObject == settings["attributesToIndex"] as! NSObject)
                    assert(content["attributesToRetrieve"] as! NSObject == NSNull())
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testClear() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                index.beginTransaction()
                index.clearIndex() { (content, error) in
                    guard let content = content else { assert(false); return }
                    assert(content["updatedAt"] as? String != nil)
                    index.commitTransaction() { (content, error) in
                        guard error == nil else { assert(false); return }
                        index.browse(Query()) { (content, error) in
                            guard let content = content else { assert(false); return }
                            guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                            assert(nbHits == 0)
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testBrowse() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                index.browse(Query(parameters: ["hitsPerPage": "1"])) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let cursor = content["cursor"] as? String else { assert(false); return }
                    index.browseFrom(cursor) { (content, error) in
                        guard let content = content else { assert(false); return }
                        assert(content["cursor"] == nil)
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testDeleteByQuery() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                index.beginTransaction()
                index.deleteByQuery(Query(parameters: ["numericFilters": "born < 1970"])) { (content, error) in
                    assert(error == nil)
                    index.commitTransaction() { (content, error) in
                        guard error == nil else { assert(false); return }
                        index.browse(Query()) { (content, error) in
                            guard let content = content else { assert(false); return }
                            guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                            assert(nbHits == 1)
                            assert(content["cursor"] == nil)
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testMultipleQueries() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                index.multipleQueries([Query(query: "snoopy"), Query(query: "woodstock")]) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let results = content["results"] as? [[String: AnyObject]] else { assert(false); return }
                    assert(results.count == 2)
                    for result in results {
                        guard let nbHits = result["nbHits"] as? Int else { assert(false); return }
                        assert(nbHits == 1)
                    }
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
}
