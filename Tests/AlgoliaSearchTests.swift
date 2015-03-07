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
import Alamofire

class AlgoliaSearchTests: XCTestCase {
    let expectationTimeout: NSTimeInterval = 100
    
    var client: Client!
    var index: Index!
    
    override func setUp() {
        super.setUp()
        let appID = NSProcessInfo.processInfo().environment["ALGOLIA_APPLICATION_ID"] as String
        let apiKey = NSProcessInfo.processInfo().environment["ALGOLIA_API_KEY"] as String
        client = AlgoliaSearch.Client(appID: appID, apiKey: apiKey)
        index = client.getIndex("algol?à-swift")
        
        let expectation = expectationWithDescription("Delete index")
        client.deleteIndex(index.indexName, block: { (JSON, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let expectation = expectationWithDescription("Delete index")
        client.deleteIndex(index.indexName, block: { (JSON, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testAdd() {
        let expectation = expectationWithDescription("testAdd")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                        
                        self.index.search(Query(), block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during search: \(error)")
                            } else {
                                let nbHits = JSON!["nbHits"] as Int
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
    
    func testAddWithObjectID() {
        let expectation = expectationWithDescription("testAddWithObjectID")
        let object = ["city": "San José"]
        let objectID = "a/go/?à-2"
        
        index.addObject(object, withID: objectID, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                        
                        self.index.getObject(objectID, block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getObject: \(error)")
                            } else {
                                let city = JSON!["city"] as String
                                XCTAssertEqual(city, object["city"]!, "Get object return a bad object")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testDelete() {
        let expectation = expectationWithDescription("testDelete")
        let object = ["city": "Las Vegas", "objectID": "a/go/?à-3"]
        
        index.addObject(object, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.deleteObject(object["objectID"]!, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during deleteObject: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                                
                                self.index.search(Query(), block: { (JSON, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during search")
                                    } else {
                                        let nbHits = JSON!["nbHits"] as Int
                                        XCTAssertEqual(nbHits, 0, "Wrong number of object in the index")
                                    }
                                    
                                    expectation.fulfill()
                                })
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testGet() {
        let expectation = expectationWithDescription("testGet")
        let object = ["city": "Los Angeles", "objectID": "a/go/?à-4"]
        
        index.addObject(object, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                        
                        self.index.getObject(object["objectID"]!, block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getObject: \(error)")
                            } else {
                                let city = JSON!["city"] as String
                                XCTAssertEqual(city, object["city"]!, "Get object return a bad object")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testPartialUpdateObject() {
        let expectation = expectationWithDescription("testPartialUpdateObject")
        let object = ["city": "New York", "initial": "NY", "objectID": "a/go/?à-5"]
        
        index.addObject(object, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject")
                expectation.fulfill()
            } else {
                self.index.partialUpdateObject(["city": "Los Angeles"], objectID: object["objectID"]!, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during partialUpdateObject")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask")
                                expectation.fulfill()
                            } else {
                                XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                                
                                self.index.getObject(object["objectID"]!, block: { (JSON, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getObject")
                                    } else {
                                        let city = JSON!["city"] as String
                                        let initial = JSON!["initial"] as String
                                        XCTAssertEqual(city, "Los Angeles", "Partial update is not applied")
                                        XCTAssertEqual(initial, "NY", "Partial update failed")
                                    }
                                    
                                    expectation.fulfill()
                                })
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testSaveObject() {
        let expectation = expectationWithDescription("testSaveObject")
        let object = ["city": "New York", "initial": "NY", "objectID": "a/go/?à-6"]
        
        index.addObject(object, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject")
                expectation.fulfill()
            } else {
                self.index.saveObject(["city": "Los Angeles", "objectID": "a/go/?à-6"], block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during saveObject")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask")
                                expectation.fulfill()
                            } else {
                                XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                                
                                self.index.getObject(object["objectID"]!, block: { (JSON, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getObject")
                                    } else {
                                        let city = JSON!["city"] as String
                                        let initial: AnyObject? = JSON!["initial"]
                                        XCTAssertEqual(city, "Los Angeles", "Save object is not applied")
                                        XCTAssertNil(initial, "Save object failed")
                                    }
                                    
                                    expectation.fulfill()
                                })
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testClear() {
        let expectation = expectationWithDescription("testClear")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject")
                expectation.fulfill()
            } else {
                self.index.clearIndex(block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during clearIndex")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask")
                                expectation.fulfill()
                            } else {
                                XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                                
                                self.index.search(Query(), block: { (JSON, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during search")
                                    } else {
                                        let nbHits = JSON!["nbHits"] as Int
                                        XCTAssertEqual(nbHits, 0, "Clear index failed")
                                    }
                                    
                                    expectation.fulfill()
                                })
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testSettings() {
        let expectation = expectationWithDescription("testSettings")
        let settings = ["attributesToRetrieve": ["name"]]
        
        index.setSettings(settings, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during setSettings")
                expectation.fulfill()
            } else {
                self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask")
                        expectation.fulfill()
                    } else {
                        XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                        
                        self.index.getSettings({ (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getSettings")
                            } else {
                                let attributesToRetrieve = JSON!["attributesToRetrieve"] as [String]
                                XCTAssertEqual(attributesToRetrieve, settings["attributesToRetrieve"]!, "Set settings failed")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testBrowse() {
        let expectation = expectationWithDescription("testBrowse")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject")
                expectation.fulfill()
            } else {
                self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask")
                        expectation.fulfill()
                    } else {
                        XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                        
                        self.index.browse(page: 0, block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during browse")
                            } else {
                                let nbHits = JSON!["nbHits"] as Int
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
    
    func testBrowseWithHitsPerPage() {
        let expectation = expectationWithDescription("testBrowseWithHitsPerPage")
        let objects = [
            ["city": "San Francisco", "objectID": "a/go/?à"],
            ["city": "New York", "objectID": "a/go/?à-1"]
        ]
        
        index.addObjects(objects, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects")
                expectation.fulfill()
            } else {
                self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask")
                        expectation.fulfill()
                    } else {
                        XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                        
                        self.index.browse(page: 0, hitsPerPage: 1, block: { (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during browse")
                            } else {
                                let nbPages = JSON!["nbPages"] as Int
                                XCTAssertEqual(nbPages, 2, "Wrong number of page")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })

        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testListIndexes() {
        let expectation = expectationWithDescription("testListIndexes")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (JSON, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject")
                expectation.fulfill()
            } else {
                self.index.waitTask(JSON!["taskID"] as Int, block: { (JSON, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask")
                        expectation.fulfill()
                    } else {
                        XCTAssertEqual(JSON!["status"] as String, "published", "Wait task failed")
                        
                        self.client.listIndexes({ (JSON, error) -> Void in
                            if let error = error {
                                XCTFail("Error during listIndexes")
                            } else {
                                let items = JSON!["items"] as [[String: AnyObject]]
                                
                                var find = false
                                for item in items {
                                    if (item["name"] as String) == self.index.indexName {
                                        find = true
                                    }
                                }

                                XCTAssertTrue(find, "List indexes failed")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
}