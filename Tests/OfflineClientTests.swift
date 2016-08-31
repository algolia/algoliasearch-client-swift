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


class OfflineClientTests: OfflineTestCase {
    
    override init() {
        super.init()
        tests = [
            self.testListIndices,
            self.testDeleteIndex,
            self.testMoveIndex
        ]
    }
    
    func testListIndices() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        client.listIndexesOffline { (content, error) in
            assert(error == nil)
            guard let content = content else { assert(false); return }
            guard let items = content["items"] as? [[String: AnyObject]] else { assert(false); return }
            for item in items {
                guard let name = item["name"] as? String else { assert(false); return }
                // Check that the index does not exist yet.
                assert(name != index.name)
            }
            index.addObject(self.objects["snoopy"]!) { (content, error) in
                assert(error == nil)
                self.client.listIndexesOffline { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let items = content["items"] as? [[String: AnyObject]] else { assert(false); return }
                    var found = false
                    for item in items {
                        guard let name = item["name"] as? String else { assert(false); return }
                        // Check that the index *does* exist.
                        if name == index.name {
                            found = true
                        }
                    }
                    assert(found)
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testDeleteIndex() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            assert(self.client.hasOfflineData(index.name))
            self.client.deleteIndexOffline(index.name) { (content, error) in
                assert(error == nil)
                assert(!self.client.hasOfflineData(index.name))
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testMoveIndex() {
        let expectation = expectationWithDescription(#function)
        let srcIndex = client.getOfflineIndex(#function);
        let dstIndex = client.getOfflineIndex(#function + "_new")
        srcIndex.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            assert(self.client.hasOfflineData(srcIndex.name))
            assert(!self.client.hasOfflineData(dstIndex.name))
            self.client.moveIndexOffline(srcIndex.name, to: dstIndex.name) { (content, error) in
                assert(error == nil)
                assert(!self.client.hasOfflineData(srcIndex.name))
                assert(self.client.hasOfflineData(dstIndex.name))
                dstIndex.search(Query(query: "woodstock")) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                    assert(nbHits == 1)
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
}
