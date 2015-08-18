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

class IndexTests: XCTestCase {
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
    
    func testAdd() {
        let expectation = expectationWithDescription("testAdd")
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
                        self.index.search(Query(), block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during search: \(error)")
                            } else {
                                let nbHits = content!["nbHits"] as! Int
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
        let objectID = "a/go/?à"
        
        index.addObject(object, withID: objectID, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.getObject(objectID, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getObject: \(error)")
                            } else {
                                let city = content!["city"] as! String
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
    
    func testAddObjects() {
        let expectation = expectationWithDescription("testAddObjects")
        let objects = [
            ["city": "San Francisco"],
            ["city": "New York"]
        ]
        
        index.addObjects(objects, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.search(Query(), block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during search: \(error)")
                            } else {
                                let nbHits = content!["nbHits"] as! Int
                                XCTAssertEqual(nbHits, 2, "Wrong number of object in the index")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testWaitTask() {
        let expectation = expectationWithDescription("testWaitTask")
        let object = ["city": "Paris", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                    } else {
                        XCTAssertEqual(content!["status"] as! String, "published", "Wait task failed")
                    }
                    
                    expectation.fulfill()
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testDelete() {
        let expectation = expectationWithDescription("testDelete")
        let object = ["city": "Las Vegas", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.deleteObject(object["objectID"]!, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during deleteObject: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.search(Query(), block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during search: \(error)")
                                    } else {
                                        let nbHits = content!["nbHits"] as! Int
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
    
    func testDeleteObjects() {
        let expectation = expectationWithDescription("testDeleteObjects")
        let objects = [
            ["city": "San Francisco", "objectID": "a/go/?à"],
            ["city": "New York", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                self.index.deleteObjects(["a/go/?à", "a/go/?à$"], block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during deleteObjects: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.search(Query(), block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during search: \(error)")
                                    } else {
                                        let nbHits = content!["nbHits"] as! Int
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
        let object = ["city": "Los Angeles", "objectID": "a/go/?à"]
        
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
                        self.index.getObject(object["objectID"]!, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getObject: \(error)")
                            } else {
                                let city = content!["city"] as! String
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
    
    func testGetObjects() {
        let expectation = expectationWithDescription("testGetObjects")
        let objects = [
            ["city": "San Francisco", "objectID": "a/go/?à"],
            ["city": "New York", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjetcs: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.getObjects(["a/go/?à", "a/go/?à$"], block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getObjects: \(error)")
                            } else {
                                let items = content!["results"] as! [[String: String]]
                                XCTAssertEqual(items[0]["city"]!, objects[0]["city"]!, "GetObjects return the wrong object")
                                XCTAssertEqual(items[1]["city"]!, objects[1]["city"]!, "GetObjects return the wrong object")
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
        let object = ["city": "New York", "initial": "NY", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.partialUpdateObject(["city": "Los Angeles"], objectID: object["objectID"]!, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during partialUpdateObject: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.getObject(object["objectID"]!, block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getObject: \(error)")
                                    } else {
                                        let city = content!["city"] as! String
                                        let initial = content!["initial"] as! String
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
    
    func testPartialUpdateObjects() {
        let expectation = expectationWithDescription("testPartialUpdateObjects")
        let objects = [
            ["city": "San Francisco", "initial": "SF", "objectID": "a/go/?à"],
            ["city": "New York", "initial": "NY", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                let objectsToUpdate = [
                    ["city": "Paris", "objectID": "a/go/?à"],
                    ["city": "Strasbourg", "objectID": "a/go/?à$"]
                ]
                self.index.partialUpdateObjects(objectsToUpdate, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during partialUpdateObjects: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.getObjects(["a/go/?à", "a/go/?à$"], block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getObjects: \(error)")
                                    } else {
                                        let items = content!["results"] as! [[String: String]]
                                        XCTAssertEqual(items[0]["city"]!, "Paris", "partialUpdateObjects failed")
                                        XCTAssertEqual(items[0]["initial"]!, "SF", "partialUpdateObjects failed")
                                        XCTAssertEqual(items[1]["city"]!, "Strasbourg", "partialUpdateObjects failed")
                                        XCTAssertEqual(items[1]["initial"]!, "NY", "partialUpdateObjects failed")
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
        let object = ["city": "New York", "initial": "NY", "objectID": "a/go/?à"]
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.saveObject(["city": "Los Angeles", "objectID": "a/go/?à"], block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during saveObject: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.getObject(object["objectID"]!, block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getObject: \(error)")
                                    } else {
                                        let city = content!["city"] as! String
                                        let initial: AnyObject? = content!["initial"]
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
    
    func testSaveObjects() {
        let expectation = expectationWithDescription("testSaveObjects")
        let objects = [
            ["city": "San Francisco", "initial": "SF", "objectID": "a/go/?à"],
            ["city": "New York", "initial": "NY", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                let objectsToSave = [
                    ["city": "Paris", "objectID": "a/go/?à"],
                    ["city": "Strasbourg", "initial": "SBG", "objectID": "a/go/?à$"]
                ]
                self.index.saveObjects(objectsToSave, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during saveObjects: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.getObjects(["a/go/?à", "a/go/?à$"], block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getObjects: \(error)")
                                    } else {
                                        let items = content!["results"] as! [[String: String]]
                                        XCTAssertEqual(items[0]["city"]!, "Paris", "saveObjects failed")
                                        XCTAssertNil(items[0]["initial"], "saveObjects failed")
                                        XCTAssertEqual(items[1]["city"]!, "Strasbourg", "saveObjects failed")
                                        XCTAssertNotNil(items[1]["initial"], "saveObjects failed")
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
        
        index.addObject(object, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.clearIndex({ (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during clearIndex: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.search(Query(), block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during search: \(error)")
                                    } else {
                                        let nbHits = content!["nbHits"] as! Int
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
        
        index.setSettings(settings, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during setSettings: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.getSettings({ (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getSettings: \(error)")
                            } else {
                                let attributesToRetrieve = content!["attributesToRetrieve"] as! [String]
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
                        self.index.browse(0, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during browse: \(error)")
                            } else {
                                let nbHits = content!["nbHits"] as! Int
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
            ["city": "New York", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.browse(0, hitsPerPage: 1, block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during browse: \(error)")
                            } else {
                                let nbPages = content!["nbPages"] as! Int
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
    
    func testBrowseWithQuery() {
        let expectation = expectationWithDescription("testBrowseWithQuery")
        var objects = [AnyObject]()
        for i in 0...1500 {
            objects.append(["i": i])
        }
        
        index.addObjects(objects, block: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        let query = Query()
                        query.hitsPerPage = 10
                        
                        var n = 0;
                        
                        self.index.browse(query, block: { (iterator, end, error) -> Void in
                            if let error = error {
                                XCTFail("Error during browse: \(error)")
                                expectation.fulfill()
                            } else if end {
                                XCTAssertEqual(n, 1500 / 10, "Wrong number of page")
                                expectation.fulfill()
                            } else {
                                ++n
                                iterator.next()
                            }
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
                        self.index.addUserKey(["search"], block: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during addUserKey: \(error)")
                                expectation.fulfill()
                            } else {
                                NSThread.sleepForTimeInterval(5) // Wait the backend
                                self.index.getUserKeyACL(content!["key"] as! String, block: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getUserKeyACL: \(error)")
                                        expectation.fulfill()
                                    } else {
                                        let acls = content!["acl"] as! [String]
                                        XCTAssertEqual(acls, ["search"], "Add user key failed")
                                        
                                        self.index.updateUserKey(content!["value"] as! String, withACL: ["addObject"], block: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during updateUserKey: \(error)")
                                                expectation.fulfill()
                                            } else {
                                                NSThread.sleepForTimeInterval(5) // Wait the backend
                                                self.index.getUserKeyACL(content!["key"] as! String, block: { (content, error) -> Void in
                                                    if let error = error {
                                                        XCTFail("Error during getUserKeyACL: \(error)")
                                                        expectation.fulfill()
                                                    } else {
                                                        let acls = content!["acl"] as! [String]
                                                        XCTAssertEqual(acls, ["addObject"], "Update user key failed")
                                                        
                                                        let keyToDelete = content!["value"] as! String
                                                        self.index.deleteUserKey(keyToDelete, block: { (content, error) -> Void in
                                                            if let error = error {
                                                                XCTFail("Error during deleteUserKey: \(error)")
                                                                expectation.fulfill()
                                                            } else {
                                                                NSThread.sleepForTimeInterval(5) // Wait the backend
                                                                self.index.listUserKeys({ (content, error) -> Void in
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
