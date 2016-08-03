//
//  Copyright (c) 2015 Algolia
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

import XCTest
import AlgoliaSearch

class ClientTests: XCTestCase {
    let expectationTimeout: NSTimeInterval = 100
    
    var client: Client!
    var index: Index!
    
    override func setUp() {
        super.setUp()
        let appID = NSProcessInfo.processInfo().environment["ALGOLIA_APPLICATION_ID"] ?? APP_ID
        let apiKey = NSProcessInfo.processInfo().environment["ALGOLIA_API_KEY"] ?? API_KEY
        client = AlgoliaSearch.Client(appID: appID, apiKey: apiKey)
        index = client.getIndex(safeIndexName("algol?à-swift"))
        
        let expectation = expectationWithDescription("Delete index")
        client.deleteIndex(index.indexName, completionHandler: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let expectation = expectationWithDescription("Delete index")
        client.deleteIndex(index.indexName, completionHandler: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testListIndexes() {
        let expectation = expectationWithDescription("testListIndexes")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.client.listIndexes({ (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during listIndexes: \(error)")
                            } else {
                                let items = content!["items"] as! [[String: AnyObject]]
                                
                                var found = false
                                for item in items {
                                    if (item["name"] as! String) == self.index.indexName {
                                        found = true
                                        break
                                    }
                                }
                                
                                XCTAssertTrue(found, "List indexes failed")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testMoveIndex() {
        let expecation = expectationWithDescription("testMoveIndex")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        XCTAssertEqual((content!["status"] as! String), "published", "Wait task failed")
                        
                        self.client.moveIndex(self.index.indexName, to: safeIndexName("algol?à-swift2"), completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during moveIndex: \(error)")
                                expecation.fulfill()
                            } else {
                                self.index.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during waitTask: \(error)")
                                        expecation.fulfill()
                                    } else {
                                        let dstIndex = self.client.getIndex(safeIndexName("algol?à-swift2"))
                                        dstIndex.search(Query(), completionHandler: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during search: \(error)")
                                            } else {
                                                let nbHits = content!["nbHits"] as! Int
                                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                                            }
                                            
                                            expecation.fulfill()
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
        
        let deleteExpectation = expectationWithDescription("Delete index")
        client.deleteIndex(safeIndexName("algol?à-swift2"), completionHandler: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            deleteExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testCopyIndex() {
        let expecation = expectationWithDescription("testCopyIndex")
        let srcIndexExpectation = expectationWithDescription("srcIndex")
        let dstIndexExpectation = expectationWithDescription("dstIndex")
        
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            guard let taskID = content?["taskID"] as? Int else {
                XCTFail("Error fetching taskID")
                expecation.fulfill()
                return
            }

            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.index.waitTask(taskID, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        XCTAssertEqual((content!["status"] as! String), "published", "Wait task failed")
                        
                        self.client.copyIndex(self.index.indexName, to: safeIndexName("algol?à-swift2"), completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during copyIndex: \(error)")
                                expecation.fulfill()
                            } else {
                                self.index.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during waitTask: \(error)")
                                    } else {
                                        self.index.search(Query(), completionHandler: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during search: \(error)")
                                            } else {
                                                let nbHits = content!["nbHits"] as! Int
                                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                                            }
                                            
                                            srcIndexExpectation.fulfill()
                                        })
                                        
                                        let dstIndex = self.client.getIndex(safeIndexName("algol?à-swift2"))
                                        dstIndex.search(Query(), completionHandler: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during search: \(error)")
                                            } else {
                                                let nbHits = content!["nbHits"] as! Int
                                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                                            }
                                            
                                            dstIndexExpectation.fulfill()
                                        })
                                    }
                                    
                                    expecation.fulfill()
                                })
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
        
        let deleteExpectation = expectationWithDescription("Delete index")
        client.deleteIndex(safeIndexName("algol?à-swift2"), completionHandler: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            deleteExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testMultipleQueries() {
        let expectation = expectationWithDescription("testMultipleQueries")
        let object = ["city": "San Francisco"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        let queries = [IndexQuery(index: self.index, query: Query())]
                        
                        self.client.multipleQueries(queries, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during multipleQueries: \(error)")
                            } else {
                                let items = content!["results"] as! [[String: AnyObject]]
                                let nbHits = items[0]["nbHits"] as! Int
                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }

    func testMultipleQueries_stopIfEnoughMatches() {
        let expectation = expectationWithDescription("testMultipleQueries")
        let object = ["city": "San Francisco"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        let query = Query()
                        query.hitsPerPage = 1
                        let queries = [
                            IndexQuery(index: self.index, query: query),
                            IndexQuery(index: self.index, query: query)
                        ]
                        
                        self.client.multipleQueries(queries, strategy: .StopIfEnoughMatches, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during multipleQueries: \(error)")
                            } else {
                                let items = content!["results"] as! [[String: AnyObject]]
                                XCTAssert(items.count == 2) // each query should return an item...
                                XCTAssertEqual(items[0]["nbHits"] as? Int, 1, "Wrong number of object in the index")
                                // ... but the second query should not have been processed
                                XCTAssertEqual(items[1]["processed"] as? Bool, false)
                                XCTAssertEqual(items[1]["nbHits"] as? Int, 0, "Wrong number of object in the index")
                            }
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }

    func testHeaders() {
        // Make a call with a valid API key.
        let expectation1 = expectationWithDescription("Valid API key")
        self.client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(error)
            expectation1.fulfill()
        }
        
        // Override the API key and check the call fails.
        self.client.headers["X-Algolia-API-Key"] = "NOT_A_VALID_API_KEY"
        let expectation2 = expectationWithDescription("Invalid API key")
        self.client.listIndexes {
            (content, error) -> Void in
            XCTAssertNotNil(error)
            expectation2.fulfill()
        }

        // Restore the valid API key (otherwise tear down will fail).
        self.client.headers["X-Algolia-API-Key"] = self.client.apiKey
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testBatch() {
        let expectation = expectationWithDescription(#function)
        let actions = [
            [
                "indexName": index.indexName,
                "action": "addObject",
                "body": [ "city": "San Francisco" ]
            ],
            [
                "indexName": index.indexName,
                "action": "addObject",
                "body": [ "city": "Paris" ]
            ]
        ]
        client.batch(actions) {
            (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
            } else if let taskID = (content!["taskID"] as? [String: AnyObject])?[self.index.indexName] as? Int {
                // Wait for the batch to be processed.
                self.index.waitTask(taskID) {
                    (content, error) in
                    if error != nil {
                        XCTFail(error!.localizedDescription)
                    } else {
                        // Check that objects have been indexed.
                        self.index.search(Query(query: "Francisco")) {
                            (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(content!["nbHits"] as? Int, 1)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            } else {
                XCTFail("Could not find task ID")
            }
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testIsAlive() {
        let expectation = expectationWithDescription(#function)
        
        client.isAlive() { (content, error) -> Void in
            if let error = error {
                XCTFail(error.description)
            } else {
                XCTAssertEqual(content?["message"] as? String, "server is alive")
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }

    func testIndexNameWithSpace() {
    let expectation = expectationWithDescription(#function)
        client.deleteIndex("Index with spaces", completionHandler: { (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testUserAgentHeader() {
        // Test that the initial value of the header is correct.
        XCTAssert(client.headers["User-Agent"]?.rangeOfString("^Algolia for Swift \\([0-9.]+\\); (iOS|macOS|tvOS) \\([0-9.]+\\)$", options: .RegularExpressionSearch) != nil)
        
        // Test that changing the user agents results in a proper format.
        client.userAgents = [
            LibraryVersion(name: "ABC", version: "1.2.3"),
            LibraryVersion(name: "DEF", version: "4.5.6")
        ]
        XCTAssertEqual(client.headers["User-Agent"], "ABC (1.2.3); DEF (4.5.6)")
    }
}
