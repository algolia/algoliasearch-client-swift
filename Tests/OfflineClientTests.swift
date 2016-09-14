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
            index.beginTransaction()
            index.addObject(self.objects["snoopy"]!) { (content, error) in
                assert(error == nil)
                index.commitTransaction() { (content, error) in
                    guard error == nil else { assert(false); return }
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
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testDeleteIndex() {
        let expectation = expectationWithDescription(#function)
        let index = client.getOfflineIndex(#function)
        index.beginTransaction()
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                assert(self.client.hasOfflineData(index.name))
                self.client.deleteIndexOffline(index.name) { (content, error) in
                    guard let content = content else { assert(false); return }
                    assert(content["deletedAt"] as? String != nil)
                    assert(!self.client.hasOfflineData(index.name))
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testMoveIndex() {
        let expectation = expectationWithDescription(#function)
        let srcIndex = client.getOfflineIndex(#function);
        let dstIndex = client.getOfflineIndex(#function + "_new")
        srcIndex.beginTransaction()
        srcIndex.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            srcIndex.commitTransaction() { (content, error) in
                guard error == nil else { assert(false); return }
                assert(self.client.hasOfflineData(srcIndex.name))
                assert(!self.client.hasOfflineData(dstIndex.name))
                self.client.moveIndexOffline(srcIndex.name, to: dstIndex.name) { (content, error) in
                    guard let content = content else { assert(false); return }
                    assert(content["updatedAt"] as? String != nil)
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
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
}
