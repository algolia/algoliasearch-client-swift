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


class OfflineClientTests: OfflineTestCase {
    
    func testListIndices() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        client.listOfflineIndexes { (content, error) in
            guard error == nil, let content = content else { XCTFail(); return }
            guard let items = content["items"] as? [JSONObject] else { XCTFail(); return }
            for item in items {
                guard let name = item["name"] as? String else { XCTFail(); return }
                // Check that the index does not exist yet.
                XCTAssertNotEqual(name, index.name)
            }
            let transaction = index.newTransaction()
            transaction.saveObject(self.objects["snoopy"]!) { (content, error) in
                XCTAssertNil(error)
                transaction.commit() { (content, error) in
                    guard error == nil else { XCTFail("Error encountered"); return }
                    self.client.listOfflineIndexes { (content, error) in
                        guard error == nil, let content = content else { XCTFail(); return }
                        guard let items = content["items"] as? [[String: AnyObject]] else { XCTFail(); return }
                        var found = false
                        for item in items {
                            guard let name = item["name"] as? String else { XCTFail(); return }
                            // Check that the index *does* exist.
                            if name == index.name {
                                found = true
                            }
                        }
                        XCTAssert(found)
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }
    
    func testDeleteIndex() {
        let expectation = self.expectation(description: #function)
        let index = client.offlineIndex(withName: #function)
        let transaction = index.newTransaction()
        transaction.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            transaction.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                XCTAssert(self.client.hasOfflineData(indexName: index.name))
                self.client.deleteOfflineIndex(withName: index.name) { (content, error) in
                    guard error == nil, let content = content else { XCTFail(); return }
                    XCTAssertNotNil(content["deletedAt"] as? String)
                    XCTAssertFalse(self.client.hasOfflineData(indexName: index.name))
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }
    
    func testMoveIndex() {
        let expectation = self.expectation(description: #function)
        let srcIndex = client.offlineIndex(withName: #function);
        let dstIndex = client.offlineIndex(withName: #function + "_new")
        let transaction = srcIndex.newTransaction()
        transaction.saveObjects(Array(objects.values)) { (content, error) in
            XCTAssertNil(error)
            transaction.commit() { (content, error) in
                guard error == nil else { XCTFail(); return }
                XCTAssertTrue(self.client.hasOfflineData(indexName: srcIndex.name))
                XCTAssertFalse(self.client.hasOfflineData(indexName: dstIndex.name))
                self.client.moveOfflineIndex(from: srcIndex.name, to: dstIndex.name) { (content, error) in
                    guard error == nil, let content = content else { XCTFail(); return }
                    XCTAssertNotNil(content["updatedAt"] as? String)
                    XCTAssert(!self.client.hasOfflineData(indexName: srcIndex.name))
                    XCTAssert(self.client.hasOfflineData(indexName: dstIndex.name))
                    dstIndex.search(Query(query: "woodstock")) { (content, error) in
                        guard error == nil, let content = content else { XCTFail(); return }
                        guard let nbHits = content["nbHits"] as? Int else { XCTFail(); return }
                        XCTAssertEqual(1, nbHits)
                        expectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout:  expectationTimeout, handler: nil)
    }
}
