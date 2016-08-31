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


class OfflineClientTests /*: XCTestCase */ {
    
    var client: OfflineClient!
    var tests: [() -> ()]!
    
    init() {
        tests = [
            self.testListIndices,
            self.testDeleteIndex,
            self.testMoveIndex
        ]
    }
    
    /* override */ func setUp() {
        // super.setUp()
        if client == nil {
            client = OfflineClient(appID: String(self.dynamicType), apiKey: "NEVERMIND")
            client.enableOfflineMode("AkUGAQH/3YXDBf+GxMAFABxDbJYBbWVudCBMZSBQcm92b3N0IChBbGdvbGlhKRhjb20uYWxnb2xpYS5GYWtlVW5pdFRlc3QwLgIVANNt9d4exv+oUPNno7XkXLOQozbYAhUAzVNYI6t/KQy1eEZECvYA0/ScpQU=")
        }
    }
    
    /* override */ func tearDown() {
        // super.tearDown()
    }
    
    let objects: [String: [String: AnyObject]] = [
        "snoopy": [
            "objectID": "1",
            "name": "Snoopy",
            "kind": "dog",
            "born": 1967,
            "series": "Peanuts"
        ],
        "woodstock": [
            "objectID": "2",
            "name": "Woodstock",
            "kind": "bird",
            "born": 1970,
            "series": "Peanuts"
        ],
        ]
    
    func test() {
        for aTest in tests {
            setUp()
            aTest()
            tearDown()
        }
    }
    
    func testListIndices() {
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
                    NSLog("[TEST] OK: \(#function)")
                }
            }
        }
    }
    
    func testDeleteIndex() {
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            assert(self.client.hasOfflineData(index.name))
            self.client.deleteIndexOffline(index.name) { (content, error) in
                assert(error == nil)
                assert(!self.client.hasOfflineData(index.name))
                NSLog("[TEST] OK: \(#function)")
            }
        }
    }
    
    func testMoveIndex() {
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
                    NSLog("[TEST] OK: \(#function)")
                }
            }
        }
    }
}
