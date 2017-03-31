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

class IndexTests: OnlineTestCase {
    
    func testAdd() {
        let expectation = self.expectation(description: "testAdd")
        let object = ["city": "San Francisco"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.search(Query(), completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testAddWithObjectID() {
        let expectation = self.expectation(description: "testAddWithObjectID")
        let object = ["city": "San José"]
        let objectID = "a/go/?à"
        
        index.addObject(object, withID: objectID, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.getObject(withID: objectID, completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testAddObjects() {
        let expectation = self.expectation(description: "testAddObjects")
        let objects: [JSONObject] = [
            ["city": "San Francisco"],
            ["city": "New York"]
        ]
        
        index.addObjects(objects, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.search(Query(), completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testWaitTask() {
        let expectation = self.expectation(description: "testWaitTask")
        let object = ["city": "Paris", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                    } else {
                        XCTAssertEqual((content!["status"] as! String), "published", "Wait task failed")
                    }
                    
                    expectation.fulfill()
                })
            }
        })
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testDelete() {
        let expectation = self.expectation(description: "testDelete")
        let object = ["city": "Las Vegas", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.deleteObject(withID: object["objectID"]!, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during deleteObject: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.search(Query(), completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testDeleteObjects() {
        let expectation = self.expectation(description: "testDeleteObjects")
        let objects: [JSONObject] = [
            ["city": "San Francisco", "objectID": "a/go/?à"],
            ["city": "New York", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                self.index.deleteObjects(withIDs: ["a/go/?à", "a/go/?à$"], completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during deleteObjects: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.search(Query(), completionHandler: { (content, error) -> Void in
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
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testGet() {
        let expectation = self.expectation(description: "testGet")
        let object = ["city": "Los Angeles", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.getObject(withID: object["objectID"]!, completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testGetObjects() {
        let expectation = self.expectation(description: "testGetObjects")
        let objects: [JSONObject] = [
            ["city": "San Francisco", "objectID": "a/go/?à"],
            ["city": "New York", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjetcs: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.getObjects(withIDs: ["a/go/?à", "a/go/?à$"], completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during getObjects: \(error)")
                            } else {
                                let items = content!["results"] as! [JSONObject]
                                XCTAssertEqual(items[0]["city"] as? String, objects[0]["city"] as? String, "GetObjects return the wrong object")
                                XCTAssertEqual(items[1]["city"] as? String, objects[1]["city"] as? String, "GetObjects return the wrong object")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testGetObjectsFiltered() {
        let expectation = self.expectation(description: #function)
        let objects: [JSONObject] = [
            ["objectID": "1", "name": "Snoopy", "kind": "dog"],
            ["objectID": "2", "name": "Woodstock", "kind": "bird"]
        ]
        index.addObjects(objects, completionHandler: { (content, error) -> Void in
            guard let content = content else {
                XCTFail(String(describing: error))
                expectation.fulfill()
                return
            }
            self.index.waitTask(withID: content["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                guard error == nil else {
                    XCTFail(String(describing: error))
                    expectation.fulfill()
                    return
                }
                self.index.getObjects(withIDs: ["1", "2"], attributesToRetrieve: ["name", "nonexistent"], completionHandler: { (content, error) -> Void in
                    guard let content = content else {
                        XCTFail(String(describing: error))
                        expectation.fulfill()
                        return
                    }
                    let items = content["results"] as! [JSONObject]
                    XCTAssertEqual(2, items.count)
                    XCTAssertEqual(items[0]["name"] as? String, "Snoopy")
                    XCTAssertEqual(items[1]["name"] as? String, "Woodstock")
                    XCTAssertNil(items[0]["kind"])
                    XCTAssertNil(items[1]["kind"])
                    expectation.fulfill()
                })
            })
        })
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testPartialUpdateObject() {
        let expectation = self.expectation(description: "testPartialUpdateObject")
        let object = ["city": "New York", "initial": "NY", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.partialUpdateObject(["city": "Los Angeles"], withID: object["objectID"]!, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during partialUpdateObject: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.getObject(withID: object["objectID"]!, completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testPartialUpdateObjectCreateIfNotExists() {
        let expectation = self.expectation(description: "testPartialUpdateObject")
        let objectID = "unknown"

        // Partial update with `createIfNotExists=false` should not create object.
        self.index.partialUpdateObject(["city": "Los Angeles"], withID: objectID, createIfNotExists: false) { (content, error) -> Void in
            guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
            self.index.waitTask(withID: content!["taskID"] as! Int) { (content, error) -> Void in
                guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                self.index.getObject(withID: objectID) { (content, error) -> Void in
                    guard let error = error else {
                        XCTFail("The object should not have been created")
                        expectation.fulfill()
                        return
                    }
                    XCTAssertEqual(StatusCode.notFound.rawValue, (error as NSError).code)
                    
                    // Partial update with `createIfNotExists=true` should create object.
                    self.index.partialUpdateObject(["city": "Los Angeles"], withID: objectID, createIfNotExists: true) { (content, error) -> Void in
                        guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                        self.index.waitTask(withID: content!["taskID"] as! Int) { (content, error) -> Void in
                            guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                            self.index.getObject(withID: objectID) { (content, error) -> Void in
                                guard error == nil else {
                                    XCTFail("The object should have been created (\(error!.localizedDescription))")
                                    expectation.fulfill()
                                    return
                                }
                                XCTAssertEqual(content?["objectID"] as? String, objectID)
                                XCTAssertEqual(content?["city"] as? String, "Los Angeles")
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testPartialUpdateObjects() {
        let expectation = self.expectation(description: "testPartialUpdateObjects")
        let objects: [JSONObject] = [
            ["city": "San Francisco", "initial": "SF", "objectID": "a/go/?à"],
            ["city": "New York", "initial": "NY", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                let objectsToUpdate: [JSONObject] = [
                    ["city": "Paris", "objectID": "a/go/?à"],
                    ["city": "Strasbourg", "objectID": "a/go/?à$"]
                ]
                self.index.partialUpdateObjects(objectsToUpdate, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during partialUpdateObjects: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.getObjects(withIDs: ["a/go/?à", "a/go/?à$"], completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testPartialUpdateObjectsCreateIfNotExists() {
        let expectation = self.expectation(description: #function)
        let objectUpdates: [JSONObject] = [
            ["city": "Paris", "objectID": "a/go/?à"],
            ["city": "Strasbourg", "objectID": "a/go/?à$"]
        ]
        // Partial updates with `createIfNotExists=false` should not create objects.
        self.index.partialUpdateObjects(objectUpdates, createIfNotExists: false) { (content, error) -> Void in
            guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
            self.index.waitTask(withID: content!["taskID"] as! Int) { (content, error) -> Void in
                guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                self.index.getObjects(withIDs: ["a/go/?à", "a/go/?à$"]) { (content, error) -> Void in
                    // NOTE: Multiple get does not return an error, but simply returns `null` for missing objects.
                    guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                    guard let results = content?["results"] as? [Any] else { XCTFail("Invalid results"); expectation.fulfill(); return }
                    XCTAssertEqual(results.count, 2)
                    for i in 0..<2 {
                        XCTAssert(results[i] is NSNull)
                    }

                    // Partial updates with `createIfNotExists=true` should create objects.
                    self.index.partialUpdateObjects(objectUpdates, createIfNotExists: true) { (content, error) -> Void in
                        guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                        self.index.waitTask(withID: content!["taskID"] as! Int) { (content, error) -> Void in
                            guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                            self.index.getObjects(withIDs: ["a/go/?à", "a/go/?à$"]) { (content, error) -> Void in
                                guard error == nil else {
                                    XCTFail("Objects should have been created (\(error!.localizedDescription))")
                                    expectation.fulfill()
                                    return
                                }
                                guard let results = content?["results"] as? [JSONObject] else { XCTFail("Invalid results"); expectation.fulfill(); return }
                                XCTAssertEqual(results.count, 2)
                                for i in 0..<2 {
                                    XCTAssertEqual(results[i]["objectID"] as? String, objectUpdates[i]["objectID"] as? String)
                                }
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testSaveObject() {
        let expectation = self.expectation(description: "testSaveObject")
        let object: JSONObject = ["city": "New York", "initial": "NY", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.saveObject(["city": "Los Angeles", "objectID": "a/go/?à"], completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during saveObject: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.getObject(withID: object["objectID"]! as! String, completionHandler: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during getObject: \(error)")
                                    } else {
                                        let city = content!["city"] as! String
                                        let initial: Any? = content!["initial"]
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testSaveObjects() {
        let expectation = self.expectation(description: "testSaveObjects")
        let objects: [JSONObject] = [
            ["city": "San Francisco", "initial": "SF", "objectID": "a/go/?à"],
            ["city": "New York", "initial": "NY", "objectID": "a/go/?à$"]
        ]
        
        index.addObjects(objects, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                let objectsToSave: [JSONObject] = [
                    ["city": "Paris", "objectID": "a/go/?à"],
                    ["city": "Strasbourg", "initial": "SBG", "objectID": "a/go/?à$"]
                ]
                self.index.saveObjects(objectsToSave, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during saveObjects: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.getObjects(withIDs: ["a/go/?à", "a/go/?à$"], completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testClear() {
        let expectation = self.expectation(description: "testClear")
        let object: JSONObject = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.clearIndex(completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during clearIndex: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during waitTask: \(error)")
                                expectation.fulfill()
                            } else {
                                self.index.search(Query(), completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testSettings() {
        let expectation = self.expectation(description: "testSettings")
        let settings = ["attributesToRetrieve": ["name"]]
        
        index.setSettings(settings, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during setSettings: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.getSettings(completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testSettings_forwardToReplicas() {
        let expectation = self.expectation(description: "testSettings")
        let settings = ["attributesToRetrieve": ["name"]]
        
        index.setSettings(settings, forwardToReplicas: true, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during setSettings: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.index.getSettings(completionHandler: { (content, error) -> Void in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testBrowse() {
        let expectation = self.expectation(description: "testBrowseWithQuery")
        var objects: [JSONObject] = []
        for i in 0...1500 {
            objects.append(["i": i])
        }
        
        index.addObjects(objects, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObjects: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        let query = Query()
                        query.hitsPerPage = 1000
                        self.index.browse(query: query, completionHandler: { (content, error) -> Void in
                            if error != nil {
                                XCTFail("Error during browse: \(error!)")
                            } else {
                                if let cursor = content?["cursor"] as? String {
                                    self.index.browse(from: cursor) { (content, error) in
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testBatch() {
        let expectation = self.expectation(description: #function)
        let actions: [JSONObject] = [
            [
                "action": "addObject",
                "body": [ "city": "San Francisco" ]
            ],
            [
                "action": "addObject",
                "body": [ "city": "Paris" ]
            ]
        ]
        index.batch(operations: actions) {
            (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
            } else if let taskID = content!["taskID"] as? Int {
                // Wait for the batch to be processed.
                self.index.waitTask(withID: taskID) {
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
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testDeleteByQuery() {
        let expectation = self.expectation(description: #function)
        var objects: [JSONObject] = []
        for i in 0..<3000 {
            objects.append(["dummy": i])
        }
        
        // Add a batch of objects.
        index.addObjects(objects, completionHandler: { (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
                expectation.fulfill()
            } else {
                // Wait for the objects to be indexed.
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if error != nil {
                        XCTFail(error!.localizedDescription)
                        expectation.fulfill()
                    } else {
                        // Delete by query.
                        let query = Query()
                        query.numericFilters = ["dummy < 1500"]
                        self.index.deleteByQuery(query, completionHandler: { (content, error) -> Void in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                                expectation.fulfill()
                            } else {
                                // Check that the deleted objects no longer exist.
                                self.index.browse(query: query, completionHandler: { (content, error) in
                                    if error != nil {
                                        XCTFail(error!.localizedDescription)
                                    } else {
                                        XCTAssertEqual((content!["hits"] as? [Any])?.count, 0)
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
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testSearchDisjunctiveFaceting() {
        let expectation = self.expectation(description: "testAddObjects")
        let objects: [JSONObject] = [
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
        index.setSettings(["attributesForFaceting": ["brand", "category", "stars"]], completionHandler: { (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if error != nil {
                        XCTFail(error!.localizedDescription)
                        expectation.fulfill()
                    } else {
                        // Add objects.
                        self.index.addObjects(objects, completionHandler: { (content, error) -> Void in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                                expectation.fulfill()
                            } else {
                                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
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
                                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: { (content, error) -> Void in
                                            if error != nil {
                                                XCTFail(error!.localizedDescription)
                                                expectation.fulfill()
                                            } else {
                                                XCTAssertEqual(content!["nbHits"] as? Int, 3)
                                                let disjunctiveFacetsResult = content!["disjunctiveFacets"] as? JSONObject
                                                XCTAssertNotNil(disjunctiveFacetsResult)
                                                let brandFacetCounts = disjunctiveFacetsResult!["brand"] as? JSONObject
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
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testSearchDisjunctiveFaceting2() {
        let expectation = self.expectation(description: #function)
        let expectation1 = self.expectation(description: "empty refinements")
        let expectation2 = self.expectation(description: "stars (1 value)")
        let expectation3 = self.expectation(description: "stars (1 value) + city")
        let expectation4 = self.expectation(description: "stars (2 values) + city")
        let expectations = [expectation, expectation1, expectation2, expectation3, expectation4]
        
        let objects: [JSONObject] = [
            ["name": "Hotel A", "stars": "*", "facilities": ["wifi", "bath", "spa"], "city": "Paris"],
            ["name": "Hotel B", "stars": "*", "facilities": ["wifi"], "city": "Paris"],
            ["name": "Hotel C", "stars": "**", "facilities": ["bath"], "city": "San Fancisco"],
            ["name": "Hotel D", "stars": "****", "facilities": ["spa"], "city": "Paris"],
            ["name": "Hotel E", "stars": "****", "facilities": ["spa"], "city": "New York"]
        ]
        
        // Set index settings.
        index.setSettings(["attributesForFaceting": ["city", "stars", "facilities"]], completionHandler: { (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
                expectations.forEach() { e in e.fulfill() }
                return
            }
            self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                if error != nil {
                    XCTFail(error!.localizedDescription)
                    expectations.forEach() { e in e.fulfill() }
                    return
                }
                // Add objects.
                self.index.addObjects(objects, completionHandler: { (content, error) in
                    if error != nil {
                        XCTFail(error!.localizedDescription)
                        expectations.forEach() { e in e.fulfill() }
                        return
                    }
                    self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
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
                        
                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: { (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(5, content!["nbHits"] as? Int)
                                XCTAssertEqual(1, (content!["facets"] as? JSONObject)?.count)
                                XCTAssertEqual(2, (content!["disjunctiveFacets"] as? JSONObject)?.count)
                            }
                            expectation1.fulfill()
                        })
                        
                        refinements["stars"] = ["*"]
                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: { (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(2, content!["nbHits"] as? Int)
                                XCTAssertEqual(1, (content!["facets"] as? JSONObject)?.count)
                                let disjunctiveFacets = content!["disjunctiveFacets"] as? JSONObject
                                XCTAssertNotNil(disjunctiveFacets)
                                XCTAssertEqual(2, disjunctiveFacets?.count)
                                let starsCounts = disjunctiveFacets?["stars"] as? JSONObject
                                XCTAssertNotNil(starsCounts)
                                XCTAssertEqual(2, starsCounts?["*"] as? Int);
                                XCTAssertEqual(1, starsCounts?["**"] as? Int);
                                XCTAssertEqual(2, starsCounts?["****"] as? Int);
                            }
                            expectation2.fulfill()
                        })
                        
                        refinements["city"] = ["Paris"]
                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: { (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(2, content!["nbHits"] as? Int)
                                XCTAssertEqual(1, (content!["facets"] as? JSONObject)?.count)
                                let disjunctiveFacets = content!["disjunctiveFacets"] as? JSONObject
                                XCTAssertNotNil(disjunctiveFacets)
                                XCTAssertEqual(2, disjunctiveFacets?.count)
                                let starsCounts = disjunctiveFacets?["stars"] as? JSONObject
                                XCTAssertNotNil(starsCounts)
                                XCTAssertEqual(2, starsCounts?["*"] as? Int);
                                XCTAssertEqual(1, starsCounts?["****"] as? Int);
                            }
                            expectation3.fulfill()
                        })

                        refinements["stars"] = ["*", "****"]
                        self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: { (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(3, content!["nbHits"] as? Int)
                                XCTAssertEqual(1, (content!["facets"] as? JSONObject)?.count)
                                let disjunctiveFacets = content!["disjunctiveFacets"] as? JSONObject
                                XCTAssertNotNil(disjunctiveFacets)
                                XCTAssertEqual(2, disjunctiveFacets?.count)
                                let starsCounts = disjunctiveFacets?["stars"] as? JSONObject
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
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testDNSTimeout() {
        let expectation = self.expectation(description: #function)

        client.readHosts[0] = uniqueAlgoliaBizHost()
        
        client.listIndexes(completionHandler: {
            (content, error) -> Void in
            if let error = error {
                XCTFail("\(error)")
            }
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testTCPDrop() {
        let expectation = self.expectation(description: #function)
        
        // The host `notcp-xx-1.algolianet.com` will drop TCP connections.
        client.readHosts[0] = "notcp-xx-1.algolianet.com"
        
        client.listIndexes(completionHandler: {
            (content, error) -> Void in
            if let error = error {
                XCTFail("\(error)")
            }
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testMultipleQueries() {
        let expectation = self.expectation(description: #function)
        let object = ["city": "San Francisco"]
        
        index.addObject(object, completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        let queries = [Query()]
                        self.index.multipleQueries(queries, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during multipleQueries: \(error)")
                            } else {
                                let items = content!["results"] as! [JSONObject]
                                XCTAssertEqual(items[0]["nbHits"] as? Int, 1, "Wrong number of object in the index")
                            }
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testSearchCache() {
        let expectation = self.expectation(description: #function)
        let objects: [JSONObject] = [
            ["city": "San Francisco"],
            ["city": "New York"]
        ]
        
        let timeout: TimeInterval = 5
        index.searchCacheEnabled = true
        index.searchCacheExpiringTimeInterval = timeout
        index.addObjects(objects) { (content, error) in
            guard error == nil else {
                XCTFail(String(describing: error))
                expectation.fulfill()
                return
            }
            self.index.waitTask(withID: content!["taskID"] as! Int) { (content, error) in
                guard error == nil else {
                    XCTFail(String(describing: error))
                    expectation.fulfill()
                    return
                }
                // Search a first time: there should be no cache.
                self.index.search(Query()) { (content, error) in
                    guard error == nil else {
                        XCTFail(String(describing: error))
                        expectation.fulfill()
                        return
                    }
                    XCTAssertNotNil(content)
                    let firstResponse: JSONObject = content!

                    // Alter the hosts so that any search request should fail.
                    self.client.readHosts = ["alwaysfail.algolia.com"]
                    
                    // Search a second time with the same query: we should hit the cache and not return an error.
                    self.index.search(Query()) { (content, error) in
                        guard error == nil else {
                            XCTFail(String(describing: error))
                            expectation.fulfill()
                            return
                        }
                        XCTAssertNotNil(content)
                        XCTAssertEqual(firstResponse as NSObject, content! as NSObject)
                        
                        // Search a third time, but wait for the cache to expire.
                        DispatchQueue.main.asyncAfter(deadline: .now() + timeout * 3) {
                            self.index.search(Query()) { (content, error) in
                                XCTAssertNotNil(error)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        self.waitForExpectations(timeout: expectationTimeout + timeout * 4, handler: nil)
    }
    
    func testSearchForFacetValues() {
        let expectation = self.expectation(description: #function)
        let settings = [
            "attributesForFaceting": [
                "searchable(series)",
                "kind"
            ]
        ]
        let objects: [String: JSONObject] = [
            "snoopy": [
                "objectID": "1",
                "name": "Snoopy",
                "kind": [ "dog", "animal" ],
                "born": 1950,
                "series": "Peanuts"
            ],
            "woodstock": [
                "objectID": "2",
                "name": "Woodstock",
                "kind": ["bird", "animal" ],
                "born": 1960,
                "series": "Peanuts"
            ],
            "charlie": [
                "objectID": "3",
                "name": "Charlie Brown",
                "kind": [ "human" ],
                "born": 1950,
                "series": "Peanuts"
            ],
            "hobbes": [
                "objectID": "4",
                "name": "Hobbes",
                "kind": [ "tiger", "animal", "teddy" ],
                "born": 1985,
                "series": "Calvin & Hobbes"
            ],
            "calvin": [
                "objectID": "5",
                "name": "Calvin",
                "kind": [ "human" ],
                "born": 1985,
                "series": "Calvin & Hobbes"
            ]
        ]
        
        // Populate index.
        index.setSettings(settings) { (content, error) in
            guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
            self.index.addObjects(Array(objects.values)) { (content, error) in
                guard error == nil, let taskID = content!["taskID"] as? Int else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                self.index.waitTask(withID: taskID) { (content, error) in
                    guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                    // Query with no extra search parameters.
                    self.index.searchForFacetValues(of: "series", matching: "Hobb") { (content, error) in
                        guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                        guard let facetHits = content!["facetHits"] as? [JSONObject] else { XCTFail("No facet hits"); expectation.fulfill(); return }
                        XCTAssertEqual(facetHits.count, 1)
                        XCTAssertEqual(facetHits[0]["value"] as? String, "Calvin & Hobbes")
                        XCTAssertEqual(facetHits[0]["count"] as? Int, 2)
                        // Query with extra search parameters.
                        let query = Query()
                        query.facetFilters = ["kind:animal"]
                        query.numericFilters = ["born >= 1955"]
                        self.index.searchForFacetValues(of: "series", matching: "Peanutz", query: query) { (content, error) in
                            guard error == nil else { XCTFail(error!.localizedDescription); expectation.fulfill(); return }
                            guard let facetHits = content!["facetHits"] as? [JSONObject] else { XCTFail("No facet hits"); expectation.fulfill(); return }
                            XCTAssertEqual(facetHits[0]["value"] as? String, "Peanuts")
                            XCTAssertEqual(facetHits[0]["count"] as? Int, 1)
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
}
