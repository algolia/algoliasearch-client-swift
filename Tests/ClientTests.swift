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
        client.deleteIndex(index.indexName, block: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let expectation = expectationWithDescription("Delete index")
        client.deleteIndex(index.indexName, block: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testListIndexes() {
        let expectation = expectationWithDescription("testListIndexes")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
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
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        XCTAssertEqual(content!["status"] as! String, "published", "Wait task failed")
                        
                        self.client.moveIndex(self.index.indexName, to: safeIndexName("algol?à-swift2"), block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during moveIndex: \(error)")
                                expecation.fulfill()
                            } else {
                                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during waitTask: \(error)")
                                        expecation.fulfill()
                                    } else {
                                        let dstIndex = self.client.getIndex(safeIndexName("algol?à-swift2"))
                                        dstIndex.search(Query(), block: { (content, error) -> Void in
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
        client.deleteIndex(safeIndexName("algol?à-swift2"), block: { (content, error) -> Void in
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
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        XCTAssertEqual(content!["status"] as! String, "published", "Wait task failed")
                        
                        self.client.copyIndex(self.index.indexName, to: safeIndexName("algol?à-swift2"), block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during copyIndex: \(error)")
                                expecation.fulfill()
                            } else {
                                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during waitTask: \(error)")
                                    } else {
                                        self.index.search(Query(), block: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during search: \(error)")
                                            } else {
                                                let nbHits = content!["nbHits"] as! Int
                                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                                            }
                                            
                                            srcIndexExpectation.fulfill()
                                        })
                                        
                                        let dstIndex = self.client.getIndex(safeIndexName("algol?à-swift2"))
                                        dstIndex.search(Query(), block: { (content, error) -> Void in
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
        client.deleteIndex(safeIndexName("algol?à-swift2"), block: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            deleteExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testGetLogs() {
        let expecation = expectationWithDescription("testGetLogs")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        self.client.getLogs({ (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getLogs: \(error)")
                            } else {
                                let logs = content!["logs"] as! [AnyObject]
                                XCTAssertNotEqual(logs.count, 0, "Get logs failed")
                            }
                            
                            expecation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testGetLogsWithOffset() {
        let expecation = expectationWithDescription("testGetLogsWithOffset")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        self.client.getLogsWithOffset(0, length: 1, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getLogs: \(error)")
                            } else {
                                let logs = content!["logs"] as! [AnyObject]
                                XCTAssertEqual(logs.count, 1, "Get logs failed")
                            }
                            
                            expecation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testGetLogsWithType() {
        let expecation = expectationWithDescription("testGetLogsWithType")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        self.client.getLogsWithType("build", offset: 0, length: 1, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getLogs: \(error)")
                            } else {
                                let logs = content!["logs"] as! [AnyObject]
                                XCTAssertEqual(logs.count, 1, "Get logs failed")
                            }
                            
                            expecation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testMultipleQueries() {
        let expectation = expectationWithDescription("testMultipleQueries")
        let object = ["city": "San Francisco"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        let queries = [["indexName": self.index.indexName, "query": Query()]]
                        
                        self.client.multipleQueries(queries, block: { (content, error) -> Void in
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
    
    func testKeyOperations() {
        let expectation = expectationWithDescription("testKeyOperations")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.client.addUserKey(["search"], block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during addUserKey: \(error)")
                                expectation.fulfill()
                            } else {
                                NSThread.sleepForTimeInterval(5) // Wait the backend
                                self.client.getUserKeyACL(content!["key"] as! String, block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getUserKeyACL: \(error)")
                                        expectation.fulfill()
                                    } else {
                                        let acls = content!["acl"] as! [String]
                                        XCTAssertEqual(acls, ["search"], "Add user key failed")
                                        
                                        self.client.updateUserKey(content!["value"] as! String, withACL: ["addObject"], block: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during updateUserKey: \(error)")
                                                expectation.fulfill()
                                            } else {
                                                NSThread.sleepForTimeInterval(5) // Wait the backend
                                                self.client.getUserKeyACL(content!["key"] as! String, block: { (content, error) -> Void in
                                                    if let error = error {
                                                        XCTFail("Error during getUserKeyACL: \(error)")
                                                        expectation.fulfill()
                                                    } else {
                                                        let acls = content!["acl"] as! [String]
                                                        XCTAssertEqual(acls, ["addObject"], "Update user key failed")
                                                        
                                                        let keyToDelete = content!["value"] as! String
                                                        self.client.deleteUserKey(keyToDelete, block: { (content, error) -> Void in
                                                            if let error = error {
                                                                XCTFail("Error during deleteUserKey: \(error)")
                                                                expectation.fulfill()
                                                            } else {
                                                                NSThread.sleepForTimeInterval(5) // Wait the backend
                                                                self.client.listUserKeys({ (content, error) -> Void in
                                                                    if let error = error {
                                                                        XCTFail("Error during listUserKeys: \(error)")
                                                                    } else {
                                                                        let keys = content!["keys"] as! [[String: AnyObject]]
                                                                        
                                                                        var found = false
                                                                        for key in keys {
                                                                            if (key["value"] as! String) == keyToDelete {
                                                                                found = true
                                                                                break;
                                                                            }
                                                                        }
                                                                        
                                                                        XCTAssertTrue(!found, "DeleteUserKey failed")
                                                                    }
                                                                    
                                                                    expectation.fulfill()
                                                                })
                                                            }
                                                        })
                                                    }
                                                })
                                            }
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
    }
}
