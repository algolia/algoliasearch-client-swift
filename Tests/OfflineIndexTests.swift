//
//  OfflineIndexTests.swift
//  AlgoliaSearch
//
//  Created by Clément Le Provost on 26/08/16.
//  Copyright © 2016 Algolia. All rights reserved.
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
        index.addObject(objects["snoopy"]!) { (content, error) in
            guard let content = content else { assert(false); return }
            assert(content["updatedAt"] as? String != nil)
            guard let objectID = content["objectID"] as? String else { assert(false); return }
            assert(objectID == "1")
            index.getObject("1") { (content, error) in
                guard let content = content else { assert(false); return }
                guard let name = content["name"] as? String else { assert(false); return }
                assert(name == "Snoopy")
                index.deleteObject("1") { (content, error) in
                    guard let content = content else { assert(false); return }
                    assert(content["deletedAt"] as? String != nil)
                    index.getObject("1") { (content, error) in
                        assert(error != nil)
                        assert(error!.code == 404)
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testAddWithIDGetDeleteObject() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.addObject(["name": "unknown"], withID: "xxx") { (content, error) in
            guard let content = content else { assert(false); return }
            assert(content["updatedAt"] as? String != nil)
            guard let objectID = content["objectID"] as? String else { assert(false); return }
            assert(objectID == "xxx")
            index.getObject("xxx") { (content, error) in
                guard let content = content else { assert(false); return }
                guard let name = content["name"] as? String else { assert(false); return }
                assert(name == "unknown")
                index.deleteObject("xxx") { (content, error) in
                    guard let content = content else { assert(false); return }
                    assert(content["deletedAt"] as? String != nil)
                    index.getObject("xxx") { (content, error) in
                        assert(error != nil)
                        assert(error!.code == 404)
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testAddGetDeleteObjects() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            guard let content = content else { assert(false); return }
            assert(content["objectIDs"] as? [AnyObject] != nil)
            index.getObjects(["1", "2"]) { (content, error) in
                guard let content = content else { assert(false); return }
                guard let items = content["results"] as? [[String: AnyObject]] else { assert(false); return }
                assert(items.count == 2)
                assert(items[0]["name"] as! String == "Snoopy")
                index.deleteObjects(["1", "2"]) { (content, error) in
                    guard let content = content else { assert(false); return }
                    assert(content["objectIDs"] as? [AnyObject] != nil)
                    index.getObject("2") { (content, error) in
                        assert(error != nil)
                        assert(error!.code == 404)
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testSearch() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
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
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testGetSetSettings() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        let settings: [String: AnyObject] = [
            "attributesToIndex": ["foo", "bar"]
        ]
        index.setSettings(settings) { (content, error) in
            assert(error == nil)
            index.getSettings() { (content, error) in
                guard let content = content else { assert(false); return }
                assert(content["attributesToIndex"] as! NSObject == settings["attributesToIndex"] as! NSObject)
                assert(content["attributesToRetrieve"] as! NSObject == NSNull())
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testClear() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.clearIndex() { (content, error) in
                guard let content = content else { assert(false); return }
                assert(content["updatedAt"] as? String != nil)
                index.browse(Query()) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                    assert(nbHits == 0)
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testBrowse() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
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
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testDeleteByQuery() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.deleteByQuery(Query(parameters: ["numericFilters": "born < 1970"])) { (content, error) in
                assert(error == nil)
                index.browse(Query()) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                    assert(nbHits == 1)
                    assert(content["cursor"] == nil)
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testMultipleQueries() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
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
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
}
