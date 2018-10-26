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

import InstantSearchClient
import PromiseKit
import XCTest

class IndexTests: OnlineTestCase {
  func testAdd() {
    let expectation = self.expectation(description: #function)
    let mockObject = ["city": "San Francisco"]

    let promise = firstly {
      self.addObject(mockObject)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.query()
    }

    promise.then { content in
      self.getHitsCount(content)
    }.then { hitsCount in
      XCTAssertEqual(hitsCount, 1, "Wrong number of object in the index")
    }.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testAddObjects() {
    let expectation = self.expectation(description: #function)
    let mockObjects: [[String: Any]] = [
      ["city": "San Francisco"],
      ["city": "New York"],
    ]

    let promise = firstly {
      self.addObjects(mockObjects)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.query()
    }

    promise.then { content in
      self.getValuePromise(content, key: "nbHits")
    }.then { hitsCount in
      XCTAssertEqual(hitsCount, 2, "Wrong number of object in the index")
    }.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testWaitTask() {
    let expectation = self.expectation(description: "testWaitTask")
    let mockObject = ["city": "Paris", "objectID": "a/go/?à"]

    let promise = firstly {
      self.addObject(mockObject)
    }.then { object in
      self.waitTask(object)
    }

    promise.then { waitContent in
      self.getValuePromise(waitContent, key: "status")
    }.then { status in
      XCTAssertEqual(status, "published", "Wait task failed")
    }.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testDelete() {
    let expectation = self.expectation(description: #function)
    let mockObject = ["city": "Las Vegas", "objectID": "a/go/?à"]

    let promise = firstly {
      self.addObject(mockObject)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.deleteObject(mockObject)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.query()
    }

    promise.then { content in
      self.getHitsCount(content)
    }.then { hitsCount in
      XCTAssertEqual(hitsCount, 0, "Wrong number of object in the index")
    }.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testDeleteObjects() {
    let expectation = self.expectation(description: #function)
    let mockObjects: [[String: Any]] = [
      ["city": "San Francisco", "objectID": "a/go/?à"],
      ["city": "New York", "objectID": "a/go/?à$"],
    ]

    let mockObjectsIDs = mockObjects.flatMap { $0["objectID"] as? String }

    let promise = firstly {
      self.addObjects(mockObjects)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.deleteObjects(mockObjectsIDs)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.query()
    }

    promise.then { content in
      self.getHitsCount(content)
    }.then { hitsCount in
      XCTAssertEqual(hitsCount, 0, "Wrong number of object in the index")
    }.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testGet() {
    let expectation = self.expectation(description: #function)
    let object = ["city": "Los Angeles", "objectID": "a/go/?à"]
    let objectId = object["objectID"]!
    let expectedCity = object["city"]!

    let promise = firstly {
      self.addObject(object)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.getObject(objectId)
    }.then { content in
      self.getValuePromise(content, key: "city")
    }.then { actualyCity in
      XCTAssertEqual(expectedCity, actualyCity, "Get object return a bad object")
    }

    promise.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testGetObjects() {
    let expectation = self.expectation(description: #function)
    let mockObjects: [[String: Any]] = [
      ["city": "San Francisco", "objectID": "a/go/?à"],
      ["city": "New York", "objectID": "a/go/?à$"],
    ]

    let mockObjectsIds: [String] = mockObjects.flatMap({ $0["objectID"] as? String })
    let mockObjectsValues: [String] = mockObjects.flatMap({ $0["city"] as? String })

    func assertSameCities(expected: [String], actual: [String: Any]) {
      let cityObjects = actual["results"] as? [[String: Any]]
      guard let cities = cityObjects?.flatMap({ $0["city"] as? String }) else {
        XCTFail("GetObjects return the wrong object")
        return
      }
      XCTAssertEqual(cities, expected, "GetObjects return the wrong object")
    }

    let promise = firstly {
      self.addObjects(mockObjects)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.getObjects(mockObjectsIds)
    }.then { objectsContent in
      assertSameCities(expected: mockObjectsValues, actual: objectsContent)
    }

    promise.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testGetObjectsFiltered() {
    let expectation = self.expectation(description: #function)
    let mockObjects: [[String: Any]] = [
      ["objectID": "1", "name": "Snoopy", "kind": "dog"],
      ["objectID": "2", "name": "Woodstock", "kind": "bird"],
    ]
    let mockObjectsIds: [String] = mockObjects.flatMap({ $0["objectID"] as? String })
    let mockObjectsNames: [String] = mockObjects.flatMap({ $0["name"] as? String })

    let promise = firstly {
      self.addObjects(mockObjects)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.getObjects(mockObjectsIds, attributesToRetrieve: ["name", "nonexistent"])
    }.then { objectsContent in
      assertSameNamesWithNoKind(expected: mockObjectsNames, actual: objectsContent)
    }

    promise.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertSameNamesWithNoKind(expected: [String], actual: [String: Any]) {
      let items = actual["results"] as! [[String: Any]]
      XCTAssertEqual(2, items.count)
      XCTAssertEqual(items[0]["name"] as? String, expected[0])
      XCTAssertEqual(items[1]["name"] as? String, expected[1])
      XCTAssertNil(items[0]["kind"])
      XCTAssertNil(items[1]["kind"])
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testPartialUpdateObject() {
    let expectation = self.expectation(description: #function)
    let mockObject = ["city": "New York", "initial": "NY", "objectID": "a/go/?à"]

    var promise = firstly {
      addObject(mockObject)
    }.then { object in
      self.waitTask(object)
    }

    promise = promise.then { _ in
      self.partialUpdateObject(["city": "Los Angeles"], withID: mockObject["objectID"]!)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.getObject(mockObject["objectID"]!)
    }.then { content in
      assertSuccessfulUpdate(content: content)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertSuccessfulUpdate(content: [String: Any]) {
      let city = content["city"] as! String
      let initial = content["initial"] as! String
      XCTAssertEqual(city, "Los Angeles", "Partial update is not applied")
      XCTAssertEqual(initial, "NY", "Partial update failed")
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testPartialUpdateObjectCreateIfNotExistsTrue() {
    let expectation = self.expectation(description: #function)
    let objectID = "unknown"

    let promise = firstly {
      self.partialUpdateObject(["city": "Los Angeles"], withID: objectID, createIfNotExists: true)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.getObject(objectID)
    }.then { object in
      assertEqual(object)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      XCTAssertEqual(content["objectID"] as? String, objectID)
      XCTAssertEqual(content["city"] as? String, "Los Angeles")
    }

    waitForExpectations(timeout: expectationTimeout)
  }

  func testPartialUpdateObjectCreateIfNotExistsFalse() {
    let expectation = self.expectation(description: #function)
    let objectID = "unknown"

    let promise = firstly {
      self.partialUpdateObject(["city": "Los Angeles"], withID: objectID, createIfNotExists: false)
    }.then { object in
      self.waitTask(object)
    }

    promise.then { _ in
      self.getObject(objectID)
    }.catch { error in // The object should not have been created
      XCTAssertEqual(StatusCode.notFound.rawValue, (error as NSError).code)
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testPartialUpdateObjects() {
    let expectation = self.expectation(description: #function)
    let objects: [[String: Any]] = [
      ["city": "San Francisco", "initial": "SF", "objectID": "a/go/?à"],
      ["city": "New York", "initial": "NY", "objectID": "a/go/?à$"],
    ]

    let objectsToUpdate: [[String: Any]] = [
      ["city": "Paris", "objectID": "a/go/?à"],
      ["city": "Strasbourg", "objectID": "a/go/?à$"],
    ]

    let promise = firstly {
      self.addObjects(objects)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.partialUpdateObjects(objectsToUpdate)
    }.then { object in
      self.waitTask(object)
    }

    let promise3 = promise2.then { _ in
      self.getObjects(["a/go/?à", "a/go/?à$"])
    }.then { object in
      assertEqual(object)
    }

    promise3.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      let items = content["results"] as! [[String: String]]
      XCTAssertEqual(items[0]["city"]!, "Paris", "partialUpdateObjects failed")
      XCTAssertEqual(items[0]["initial"]!, "SF", "partialUpdateObjects failed")
      XCTAssertEqual(items[1]["city"]!, "Strasbourg", "partialUpdateObjects failed")
      XCTAssertEqual(items[1]["initial"]!, "NY", "partialUpdateObjects failed")
    }

    waitForExpectations(timeout: expectationTimeout)
  }

  func testPartialUpdateObjectsCreateIfNotExistsFalse() {
    let expectation = self.expectation(description: #function)
    let objectUpdates: [[String: Any]] = [
      ["city": "Paris", "objectID": "a/go/?à"],
      ["city": "Strasbourg", "objectID": "a/go/?à$"],
    ]

    var promise = firstly {
      partialUpdateObjects(objectUpdates, createIfNotExists: false)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.getObjects(["a/go/?à", "a/go/?à$"])
    }.then { object in
      assertEqual(object)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      guard let results = content["results"] as? [Any] else {
        XCTFail("Invalid results")
        return
      }

      XCTAssertEqual(results.count, 2)
      for i in 0 ..< 2 {
        XCTAssert(results[i] is NSNull)
      }
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  // Partial updates with `createIfNotExists=true` should create objects.
  func testPartialUpdateObjectsCreateIfNotExistsTrue() {
    let expectation = self.expectation(description: #function)
    let objectUpdates: [[String: Any]] = [
      ["city": "Paris", "objectID": "a/go/?à"],
      ["city": "Strasbourg", "objectID": "a/go/?à$"],
    ]

    var promise = firstly {
      partialUpdateObjects(objectUpdates, createIfNotExists: true)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.getObjects(["a/go/?à", "a/go/?à$"])
    }.then { object in
      assertEqual(object)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      guard let results = content["results"] as? [[String: Any]] else {
        XCTFail("Invalid results")
        return
      }

      XCTAssertEqual(results.count, 2)
      for i in 0 ..< 2 {
        XCTAssertEqual(results[i]["objectID"] as? String, objectUpdates[i]["objectID"] as? String)
      }
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testSaveObject() {
    let expectation = self.expectation(description: "testSaveObject")
    let mockObject: [String: Any] = ["city": "New York", "initial": "NY", "objectID": "a/go/?à"]
    let laMockObject = ["city": "Los Angeles", "objectID": "a/go/?à"]

    func verifyCityExists(_ cityContent: [String: Any]) {
      let city = cityContent["city"] as! String
      let initial: Any? = cityContent["initial"]
      XCTAssertEqual(city, "Los Angeles", "Save object is not applied")
      XCTAssertNil(initial, "Save object failed")
    }

    let promise = firstly {
      self.addObject(mockObject)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.saveObject(laMockObject)
    }

    let promise2 = promise.then { object in
      self.waitTask(object)
    }.then { _ in
      self.getObject(mockObject["objectID"] as! String)
    }.then { cityContent in
      verifyCityExists(cityContent)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testSaveObjects() {
    let expectation = self.expectation(description: "testSaveObjects")
    let mockObjects: [[String: Any]] = [
      ["city": "San Francisco", "initial": "SF", "objectID": "a/go/?à"],
      ["city": "New York", "initial": "NY", "objectID": "a/go/?à$"],
    ]

    let objectsToSave: [[String: Any]] = [
      ["city": "Paris", "objectID": "a/go/?à"],
      ["city": "Strasbourg", "initial": "SBG", "objectID": "a/go/?à$"],
    ]

    func verifyCitiesExists(_ cities: [[String: String]]) {
      XCTAssertEqual(cities[0]["city"]!, "Paris", "saveObjects failed")
      XCTAssertNil(cities[0]["initial"], "saveObjects failed")
      XCTAssertEqual(cities[1]["city"]!, "Strasbourg", "saveObjects failed")
      XCTAssertNotNil(cities[1]["initial"], "saveObjects failed")
    }

    let promise = firstly {
      self.addObjects(mockObjects)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.saveObjects(objectsToSave)
    }

    let promise2 = promise.then { object in
      self.waitTask(object)
    }.then { _ in
      self.getObjects(["a/go/?à", "a/go/?à$"])
    }.then { citiesContent in
      verifyCitiesExists(citiesContent["results"] as! [[String: String]])
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testClear() {
    let expectation = self.expectation(description: "testClear")
    let object: [String: Any] = ["city": "San Francisco", "objectID": "a/go/?à"]

    var promise = firstly {
      addObject(object)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.clearIndex()
    }.then { object in
      self.waitTask(object)
    }

    let promise3 = promise2.then { _ in
      self.query()
    }.then { object in
      assertEqual(object)
    }

    promise3.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      let nbHits = content["nbHits"] as! Int
      XCTAssertEqual(nbHits, 0, "Clear index failed")
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testSettings() {
    let expectation = self.expectation(description: "testSettings")
    let settings = ["attributesToRetrieve": ["name"]]

    var promise = firstly {
      setSettings(settings)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.getSettings()
    }.then { object in
      assertEqual(object)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      let attributesToRetrieve = content["attributesToRetrieve"] as! [String]
      XCTAssertEqual(attributesToRetrieve, settings["attributesToRetrieve"]!, "Set settings failed")
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testSettings_forwardToReplicas() {
    let expectation = self.expectation(description: "testSettings")
    let settings = ["attributesToRetrieve": ["name"]]

    var promise = firstly {
      setSettings(settings, forwardToReplicas: true)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.getSettings()
    }.then { object in
      assertEqual(object)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      let attributesToRetrieve = content["attributesToRetrieve"] as! [String]
      XCTAssertEqual(attributesToRetrieve, settings["attributesToRetrieve"]!, "Set settings failed")
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testBrowse() {
    let expectation = self.expectation(description: "testBrowseWithQuery")
    var objects: [[String: Any]] = []
    for i in 0 ... 1500 {
      objects.append(["i": i])
    }

    let query = Query()
    query.hitsPerPage = 1000

    var promise = firstly {
      addObjects(objects)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.browse(query)
    }.then { object in
      self.getValuePromise(object, key: "cursor")
    }.then { cursor in
      self.browse(from: cursor)
    }

    promise2.then { object in
      assertEqual(object)
    }.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      if content["cursor"] as? String != nil {
        XCTFail("The end should have been reached")
      }
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testBatch() {
    let expectation = self.expectation(description: #function)
    let actions: [[String: Any]] = [
      [
        "action": "addObject",
        "body": ["city": "San Francisco"],
      ],
      [
        "action": "addObject",
        "body": ["city": "Paris"],
      ],
    ]

    let promise = firstly {
      self.batch(actions)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.query("Francisco")
    }.then { object in
      XCTAssertEqual(object["nbHits"] as? Int, 1)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testDeleteByQuery() {
    let expectation = self.expectation(description: #function)
    var objects: [[String: Any]] = []
    for i in 0 ..< 3000 {
      objects.append(["dummy": i])
    }
    let query = Query()
    query.numericFilters = ["dummy < 1500"]

    var promise = firstly {
      addObjects(objects)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.deleteByQuery(query)
    }.then { _ in
      self.browse(query)
    }.then { object in
      assertEqual(object)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      XCTAssertEqual((content["hits"] as? [Any])?.count, 0)
      XCTAssertNil(content["cursor"])
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testDeleteBy() {
    let expectation = self.expectation(description: #function)
    var objects: [[String: Any]] = []
    for i in 0 ..< 3000 {
      objects.append(["dummy": i])
    }
    let query = Query(query: "")
    query.numericFilters = ["dummy < 1500"]

    var promise = firstly {
      addObjects(objects)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.deleteBy(query)
    }.then { object in
      self.waitTask(object)
    }

    let promise3 = promise2.then { _ in
      self.browse(query)
    }.then { object in
      assertEqual(object)
    }

    promise3.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      XCTAssertEqual((content["hits"] as? [Any])?.count, 0)
      XCTAssertNil(content["cursor"])
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testSearchDisjunctiveFaceting() {
    let expectation = self.expectation(description: "testAddObjects")
    let objects: [[String: Any]] = [
      ["name": "iPhone 6", "brand": "Apple", "category": "device", "stars": 4],
      ["name": "iPhone 6 Plus", "brand": "Apple", "category": "device", "stars": 5],
      ["name": "iPhone cover", "brand": "Apple", "category": "accessory", "stars": 3],
      ["name": "Galaxy S5", "brand": "Samsung", "category": "device", "stars": 4],
      ["name": "Wonder Phone", "brand": "Samsung", "category": "device", "stars": 5],
      ["name": "Platinum Phone Cover", "brand": "Samsung", "category": "accessory", "stars": 2],
      ["name": "Lame Phone", "brand": "Whatever", "category": "device", "stars": 1],
      ["name": "Lame Phone cover", "brand": "Whatever", "category": "accessory", "stars": 1],
    ]
    let disjunctiveFacets = ["brand"]
    let refinements = [
      "brand": ["Apple", "Samsung"], // disjunctive
      "category": ["device"], // conjunctive
    ]
    let query = Query(query: "phone")
    query.facets = ["brand", "category", "stars"]

    var promise = firstly {
      setSettings(["attributesForFaceting": ["brand", "category", "stars"]])
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.addObjects(objects)
    }.then { object in
      self.waitTask(object)
    }

    let promise3 = promise2.then { _ in
      self.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements)
    }.then { object in
      assertEqual(object)
    }

    promise3.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      XCTAssertEqual(content["nbHits"] as? Int, 3)
      let disjunctiveFacetsResult = content["disjunctiveFacets"] as? [String: Any]
      XCTAssertNotNil(disjunctiveFacetsResult)
      let brandFacetCounts = disjunctiveFacetsResult!["brand"] as? [String: Any]
      XCTAssertNotNil(brandFacetCounts)
      XCTAssertEqual(brandFacetCounts!["Apple"] as? Int, 2)
      XCTAssertEqual(brandFacetCounts!["Samsung"] as? Int, 1)
      XCTAssertEqual(brandFacetCounts!["Whatever"] as? Int, 1)
      let facetsStats = content["facets_stats"] as? [String: [String: Any]]
      let starStats = facetsStats!["stars"]
      XCTAssertEqual(starStats!["max"] as? Int, 5)
      XCTAssertEqual(starStats!["min"] as? Int, 4)
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testSearchDisjunctiveFaceting2() {
    let expectation = self.expectation(description: #function)

    let objects: [[String: Any]] = [
      ["name": "Hotel A", "stars": "*", "facilities": ["wifi", "bath", "spa"], "city": "Paris"],
      ["name": "Hotel B", "stars": "*", "facilities": ["wifi"], "city": "Paris"],
      ["name": "Hotel C", "stars": "**", "facilities": ["bath"], "city": "San Fancisco"],
      ["name": "Hotel D", "stars": "****", "facilities": ["spa"], "city": "Paris"],
      ["name": "Hotel E", "stars": "****", "facilities": ["spa"], "city": "New York"],
    ]
    let query = Query(query: "h")
    query.facets = ["city"]
    let disjunctiveFacets = ["stars", "facilities"]
    var refinements = [String: [String]]()

    var promise = firstly {
      setSettings(["attributesForFaceting": ["city", "stars", "facilities"]])
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.addObjects(objects)
    }.then(execute: { (object) -> (Promise<[String: Any]>) in
      print("hi")
      return self.waitTask(object)
    })

    let promise3 = promise2.then { _ in
      self.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements)
    }.then { object in
      assertEqual1(object)
    }

    let promise4 = promise3.then {
      refinements["stars"] = ["*"]
    }.then { _ in
      self.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements)
    }.then { object in
      assertEqual2(object)
    }

    let promise5 = promise4.then {
      refinements["city"] = ["Paris"]
    }.then {
      self.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements)
    }.then { object in
      assertEqual3(object)
    }

    let promise6 = promise5.then {
      refinements["stars"] = ["*", "****"]
    }.then {
      self.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements)
    }.then { object in
      assertEqual4(object)
    }

    promise6.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual1(_ content: [String: Any]) {
      XCTAssertEqual(5, content["nbHits"] as? Int)
      XCTAssertEqual(1, (content["facets"] as? [String: Any])?.count)
      XCTAssertEqual(2, (content["disjunctiveFacets"] as? [String: Any])?.count)
    }

    func assertEqual2(_ content: [String: Any]) {
      XCTAssertEqual(2, content["nbHits"] as? Int)
      XCTAssertEqual(1, (content["facets"] as? [String: Any])?.count)
      let disjunctiveFacets = content["disjunctiveFacets"] as? [String: Any]
      XCTAssertNotNil(disjunctiveFacets)
      XCTAssertEqual(2, disjunctiveFacets?.count)
      let starsCounts = disjunctiveFacets?["stars"] as? [String: Any]
      XCTAssertNotNil(starsCounts)
      XCTAssertEqual(2, starsCounts?["*"] as? Int)
      XCTAssertEqual(1, starsCounts?["**"] as? Int)
      XCTAssertEqual(2, starsCounts?["****"] as? Int)
    }

    func assertEqual3(_ content: [String: Any]) {
      XCTAssertEqual(2, content["nbHits"] as? Int)
      XCTAssertEqual(1, (content["facets"] as? [String: Any])?.count)
      let disjunctiveFacets = content["disjunctiveFacets"] as? [String: Any]
      XCTAssertNotNil(disjunctiveFacets)
      XCTAssertEqual(2, disjunctiveFacets?.count)
      let starsCounts = disjunctiveFacets?["stars"] as? [String: Any]
      XCTAssertNotNil(starsCounts)
      XCTAssertEqual(2, starsCounts?["*"] as? Int)
      XCTAssertEqual(1, starsCounts?["****"] as? Int)
    }

    func assertEqual4(_ content: [String: Any]) {
      XCTAssertEqual(3, content["nbHits"] as? Int)
      XCTAssertEqual(1, (content["facets"] as? [String: Any])?.count)
      let disjunctiveFacets = content["disjunctiveFacets"] as? [String: Any]
      XCTAssertNotNil(disjunctiveFacets)
      XCTAssertEqual(2, disjunctiveFacets?.count)
      let starsCounts = disjunctiveFacets?["stars"] as? [String: Any]
      XCTAssertNotNil(starsCounts)
      XCTAssertEqual(2, starsCounts?["*"] as? Int)
      XCTAssertEqual(1, starsCounts?["****"] as? Int)
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testDNSTimeout() {
    let expectation = self.expectation(description: #function)

    client.readHosts[0] = uniqueAlgoliaBizHost()

    client.listIndexes(completionHandler: {
      (_, error) -> Void in
      if let error = error {
        XCTFail("\(error)")
      }
      expectation.fulfill()
    })
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testTCPDrop() {
    let expectation = self.expectation(description: #function)

    // The host `notcp-xx-1.algolianet.com` will drop TCP connections.
    client.readHosts[0] = "notcp-xx-1.algolianet.com"

    client.listIndexes(completionHandler: {
      (_, error) -> Void in
      if let error = error {
        XCTFail("\(error)")
      }
      expectation.fulfill()
    })
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testMultipleQueries() {
    let expectation = self.expectation(description: #function)
    let object = ["city": "San Francisco"]

    let promise = firstly {
      self.addObject(object)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.multipleQueries([Query()])
    }.then { (content) -> Promise<Void> in
      let items = content["results"] as! [[String: Any]]
      XCTAssertEqual(items[0]["nbHits"] as? Int, 1, "Wrong number of object in the index")
      return Promise()
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testSearchCache() {
    let expectation = self.expectation(description: #function)
    let objects: [[String: Any]] = [
      ["city": "San Francisco"],
      ["city": "New York"],
    ]
    var firstResponse: [String: Any]!

    let timeout: TimeInterval = 5
    index.searchCacheEnabled = true
    index.searchCacheExpiringTimeInterval = timeout

    var promise = firstly {
      addObjects(objects)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.query()
    }.then { (content) -> Promise<Void> in
      XCTAssertNotNil(content)
      firstResponse = content

      // Alter the hosts so that any search request should fail.
      self.client.readHosts = ["alwaysfail.algolia.com"]
      return Promise()
    }

    let promise3 = promise2.then { _ in
      self.query()
    }.then { (content) -> Promise<Void> in
      XCTAssertNotNil(content)
      XCTAssertEqual(firstResponse as NSObject, content as NSObject)
      return Promise()
    }.then { _ in
      SearchThirdTimeButWaitForCacheToExpire()
    }

    promise3.catch { error in
      XCTFail("Error : \(error)")
    }

    func SearchThirdTimeButWaitForCacheToExpire() {
      DispatchQueue.main.asyncAfter(deadline: .now() + timeout * 3) {
        self.index.search(Query()) { _, error in
          XCTAssertNotNil(error)
          expectation.fulfill()
        }
      }
    }

    waitForExpectations(timeout: expectationTimeout + timeout * 4, handler: nil)
  }

  func testSearchForFacetValues() {
    let expectation = self.expectation(description: #function)
    let settings = [
      "attributesForFaceting": [
        "searchable(series)",
        "kind",
      ],
    ]
    let objects: [String: [String: Any]] = [
      "snoopy": [
        "objectID": "1",
        "name": "Snoopy",
        "kind": ["dog", "animal"],
        "born": 1950,
        "series": "Peanuts",
      ],
      "woodstock": [
        "objectID": "2",
        "name": "Woodstock",
        "kind": ["bird", "animal"],
        "born": 1960,
        "series": "Peanuts",
      ],
      "charlie": [
        "objectID": "3",
        "name": "Charlie Brown",
        "kind": ["human"],
        "born": 1950,
        "series": "Peanuts",
      ],
      "hobbes": [
        "objectID": "4",
        "name": "Hobbes",
        "kind": ["tiger", "animal", "teddy"],
        "born": 1985,
        "series": "Calvin & Hobbes",
      ],
      "calvin": [
        "objectID": "5",
        "name": "Calvin",
        "kind": ["human"],
        "born": 1985,
        "series": "Calvin & Hobbes",
      ],
    ]
    let query = Query()
    query.facetFilters = ["kind:animal"]
    query.numericFilters = ["born >= 1955"]

    var promise = firstly {
      setSettings(settings)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.addObjects(Array(objects.values))
    }.then { object in
      self.waitTask(object)
    }

    let promise3 = promise2.then { _ in
      self.searchForFacetValues(of: "series", matching: "Hobb")
    }.then { object in
      assertEqual1(object)
    }

    let promise4 = promise3.then { _ in
      self.searchForFacetValues(of: "series", matching: "Peanutz", query: query)
    }.then { object in
      assertEqual2(object)
    }

    promise4.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual1(_ content: [String: Any]) {
      guard let facetHits = content["facetHits"] as? [[String: Any]] else {
        XCTFail("No facet hits")
        expectation.fulfill()
        return
      }
      XCTAssertEqual(facetHits.count, 1)
      XCTAssertEqual(facetHits[0]["value"] as? String, "Calvin & Hobbes")
      XCTAssertEqual(facetHits[0]["count"] as? Int, 2)
    }

    func assertEqual2(_ content: [String: Any]) {
      guard let facetHits = content["facetHits"] as? [[String: Any]] else { XCTFail("No facet hits"); expectation.fulfill(); return }
      XCTAssertEqual(facetHits[0]["value"] as? String, "Peanuts")
      XCTAssertEqual(facetHits[0]["count"] as? Int, 1)
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }
}
