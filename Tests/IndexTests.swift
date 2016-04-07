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
                        XCTAssertEqual((content!["status"] as! String), "published", "Wait task failed")
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
                        query.hitsPerPage = 1000
                        self.index.browse(query, block: { (content, error) -> Void in
                            if error != nil {
                                XCTFail("Error during browse: \(error!)")
                            } else {
                                if let cursor = content?["cursor"] as? String {
                                    self.index.browseFrom(cursor) { (content, error) in
                                        if error != nil {
                                            XCTFail("Error during browse: \(error!)")
                                        } else {
                                            if content?["cursor"] as? String != nil {
                                                XCTFail("The end should have been reached")
                                                expectation.fulfill()
                                            } else {
                                                expectation.fulfill()
                                            }
                                        }
                                    }
                                } else {
                                    XCTFail("The end should not be reached")
                                    expectation.fulfill()
                                }
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    func testBatch() {
        let expectation = expectationWithDescription(#function)
        let actions = [
            [
                "action": "addObject",
                "body": [ "city": "San Francisco" ]
            ],
            [
                "action": "addObject",
                "body": [ "city": "Paris" ]
            ]
        ]
        index.batch(actions) {
            (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
            } else if let taskID = content!["taskID"] as? Int {
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
    
    func testDeleteByQuery() {
        let expectation = expectationWithDescription(#function)
        var objects: [AnyObject] = []
        for i in 0..<3000 {
            objects.append(["dummy": i])
        }
        
        // Add a batch of objects.
        index.addObjects(objects, block: { (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
                expectation.fulfill()
            } else {
                // Wait for the objects to be indexed.
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if error != nil {
                        XCTFail(error!.localizedDescription)
                        expectation.fulfill()
                    } else {
                        // Delete by query.
                        let query = Query()
                        query["numericFilters"] = "dummy < 1500"
                        self.index.deleteByQuery(query, block: { (content, error) -> Void in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                                expectation.fulfill()
                            } else {
                                // Check that the deleted objects no longer exist.
                                self.index.browse(query, block: { (content, error) in
                                    if error != nil {
                                        XCTFail(error!.localizedDescription)
                                    } else {
                                        XCTAssertEqual((content!["hits"] as? [AnyObject])?.count, 0)
                                        XCTAssertNil(content!["cursor"])
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
    
    func testSearchDisjunctiveFaceting() {
        let expectation = expectationWithDescription("testAddObjects")
        let objects = [
            ["name": "iPhone 6",                "brand": "Apple",       "category": "device",       "stars": 4],
            ["name": "iPhone 6 Plus",           "brand": "Apple",       "category": "device",       "stars": 5],
            ["name": "iPhone cover",            "brand": "Apple",       "category": "accessory",    "stars": 3],
            ["name": "Galaxy S5",               "brand": "Samsung",     "category": "device",       "stars": 4],
            ["name": "Wonder Phone",            "brand": "Samsung",     "category": "device",       "stars": 5],
            ["name": "Platinum Phone Cover",    "brand": "Samsung",     "category": "accessory",    "stars": 2],
            ["name": "Lame Phone",              "brand": "Whatever",    "category": "device",       "stars": 1],
            ["name": "Lame Phone cover",        "brand": "Whatever",    "category": "accessory",    "stars": 1]
        ]
        
        // Change index settings.
        index.setSettings(["attributesForFaceting": ["brand", "category", "stars"]], block: { (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
                expectation.fulfill()
            } else {
                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                    if error != nil {
                        XCTFail(error!.localizedDescription)
                        expectation.fulfill()
                    } else {
                        // Add objects.
                        self.index.addObjects(objects, block: { (content, error) -> Void in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                                expectation.fulfill()
                            } else {
                                self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                                    if error != nil {
                                        XCTFail(error!.localizedDescription)
                                        expectation.fulfill()
                                    } else {
                                        // Search.
                                        let disjunctiveFacets = ["brand"]
                                        let refinements = [
                                            "brand": ["Apple", "Samsung"], // disjunctive
                                            "category": ["device"] // conjunctive
                                        ]
                                        let query = Query(query: "phone")
                                        query.facets = ["brand", "category", "stars"]
                                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, block: { (content, error) -> Void in
                                            if error != nil {
                                                XCTFail(error!.localizedDescription)
                                                expectation.fulfill()
                                            } else {
                                                print(content)
                                                
                                                XCTAssertEqual(content!["nbHits"] as? Int, 3)
                                                let disjunctiveFacetsResult = content!["disjunctiveFacets"] as? [String: AnyObject]
                                                XCTAssertNotNil(disjunctiveFacetsResult)
                                                let brandFacetCounts = disjunctiveFacetsResult!["brand"] as? [String: AnyObject]
                                                XCTAssertNotNil(brandFacetCounts)
                                                XCTAssertEqual(brandFacetCounts!["Apple"] as? Int, 2)
                                                XCTAssertEqual(brandFacetCounts!["Samsung"] as? Int, 1)
                                                XCTAssertEqual(brandFacetCounts!["Whatever"] as? Int, 1)
                                                expectation.fulfill()
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
    
    func testSearchDisjunctiveFaceting2() {
        let expectation = expectationWithDescription(#function)
        let expectation1 = expectationWithDescription("empty refinements")
        let expectation2 = self.expectationWithDescription("stars (1 value)")
        let expectation3 = self.expectationWithDescription("stars (1 value) + city")
        let expectation4 = self.expectationWithDescription("stars (2 values) + city")
        let expectations = [expectation, expectation1, expectation2, expectation3, expectation4]
        
        let objects = [
            ["name": "Hotel A", "stars": "*", "facilities": ["wifi", "bath", "spa"], "city": "Paris"],
            ["name": "Hotel B", "stars": "*", "facilities": ["wifi"], "city": "Paris"],
            ["name": "Hotel C", "stars": "**", "facilities": ["bath"], "city": "San Fancisco"],
            ["name": "Hotel D", "stars": "****", "facilities": ["spa"], "city": "Paris"],
            ["name": "Hotel E", "stars": "****", "facilities": ["spa"], "city": "New York"]
        ]
        
        // Set index settings.
        index.setSettings(["attributesForFaceting": ["city", "stars", "facilities"]], block: { (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
                expectations.forEach() { e in e.fulfill() }
                return
            }
            self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                if error != nil {
                    XCTFail(error!.localizedDescription)
                    expectations.forEach() { e in e.fulfill() }
                    return
                }
                // Add objects.
                self.index.addObjects(objects, block: { (content, error) in
                    if error != nil {
                        XCTFail(error!.localizedDescription)
                        expectations.forEach() { e in e.fulfill() }
                        return
                    }
                    self.index.waitTask(content!["taskID"] as! Int, block: { (content, error) -> Void in
                        if error != nil {
                            XCTFail(error!.localizedDescription)
                            expectations.forEach() { e in e.fulfill() }
                            return
                        }
                        // Search.
                        let query = Query(query: "h")
                        query.facets = ["city"]
                        let disjunctiveFacets = ["stars", "facilities"]
                        var refinements = [String: [String]]()
                        
                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, block: { (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(5, content!["nbHits"] as? Int)
                                XCTAssertEqual(1, (content!["facets"] as? [String: AnyObject])?.count)
                                XCTAssertEqual(2, (content!["disjunctiveFacets"] as? [String: AnyObject])?.count)
                            }
                            expectation1.fulfill()
                        })
                        
                        refinements["stars"] = ["*"]
                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, block: { (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(2, content!["nbHits"] as? Int)
                                XCTAssertEqual(1, (content!["facets"] as? [String: AnyObject])?.count)
                                let disjunctiveFacets = content!["disjunctiveFacets"] as? [String: AnyObject]
                                XCTAssertNotNil(disjunctiveFacets)
                                XCTAssertEqual(2, disjunctiveFacets?.count)
                                let starsCounts = disjunctiveFacets?["stars"] as? [String: AnyObject]
                                XCTAssertNotNil(starsCounts)
                                XCTAssertEqual(2, starsCounts?["*"] as? Int);
                                XCTAssertEqual(1, starsCounts?["**"] as? Int);
                                XCTAssertEqual(2, starsCounts?["****"] as? Int);
                            }
                            expectation2.fulfill()
                        })
                        
                        refinements["city"] = ["Paris"]
                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, block: { (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(2, content!["nbHits"] as? Int)
                                XCTAssertEqual(1, (content!["facets"] as? [String: AnyObject])?.count)
                                let disjunctiveFacets = content!["disjunctiveFacets"] as? [String: AnyObject]
                                XCTAssertNotNil(disjunctiveFacets)
                                XCTAssertEqual(2, disjunctiveFacets?.count)
                                let starsCounts = disjunctiveFacets?["stars"] as? [String: AnyObject]
                                XCTAssertNotNil(starsCounts)
                                XCTAssertEqual(2, starsCounts?["*"] as? Int);
                                XCTAssertEqual(1, starsCounts?["****"] as? Int);
                            }
                            expectation3.fulfill()
                        })

                        refinements["stars"] = ["*", "****"]
                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, block: { (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(3, content!["nbHits"] as? Int)
                                XCTAssertEqual(1, (content!["facets"] as? [String: AnyObject])?.count)
                                let disjunctiveFacets = content!["disjunctiveFacets"] as? [String: AnyObject]
                                XCTAssertNotNil(disjunctiveFacets)
                                XCTAssertEqual(2, disjunctiveFacets?.count)
                                let starsCounts = disjunctiveFacets?["stars"] as? [String: AnyObject]
                                XCTAssertNotNil(starsCounts)
                                XCTAssertEqual(2, starsCounts?["*"] as? Int);
                                XCTAssertEqual(1, starsCounts?["****"] as? Int);
                            }
                            expectation4.fulfill()
                        })
                        
                        expectation.fulfill()
                    })
                })
            })
        })
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
}
