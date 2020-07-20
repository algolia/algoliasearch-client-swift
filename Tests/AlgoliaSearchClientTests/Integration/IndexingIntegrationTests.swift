//
//  IndexingIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class IndexingIntegrationTests: OnlineTestCase {
  
  override var indexNameSuffix: String? {
    return "indexing"
  }
  
  func testIndexing() throws {
    
    let objectID = ObjectID(rawValue: .init(randomWithLength: 10))
    let object = TestRecord(objectID: objectID)
    
    let objectCreation = try index.saveObject(object)
    try objectCreation.wait()
    XCTAssertEqual(objectCreation.task.objectID, objectID)
    
    var objectWithGeneratedID = TestRecord()
    let objectWithGeneratedIDCreation = try index.saveObject(objectWithGeneratedID, autoGeneratingObjectID: true)
    try objectWithGeneratedIDCreation.wait()

    let generatedObjectID = objectWithGeneratedIDCreation.task.objectID
    objectWithGeneratedID.objectID = generatedObjectID
            
    let emptyObjectsCreation = try index.saveObjects([JSON]())
    try emptyObjectsCreation.wait()
      
    let objectsIDs: [ObjectID] = [.init(rawValue: .init(randomWithLength: 10)), .init(rawValue: .init(randomWithLength: 10))]
    let objects = objectsIDs.map(TestRecord.init)
    let objectsCreation = try index.saveObjects(objects)
    try objectsCreation.wait()

    XCTAssertEqual(objectsCreation.batchesResponse.objectIDs, objectsIDs)
    
    var objectsWithGeneratedID = [TestRecord(), TestRecord()]
    let objectsWithGeneratedIDCreation = try index.saveObjects(objectsWithGeneratedID, autoGeneratingObjectID: true)
    try objectWithGeneratedIDCreation.wait()

    let generatedObjectIDs = objectsWithGeneratedIDCreation.batchesResponse.objectIDs.compactMap { $0 }
    objectsWithGeneratedID = zip(objectsWithGeneratedID, generatedObjectIDs).map { $0.0.set(\.objectID, to: $0.1) }
    
    var batchRecords: [TestRecord] = []
    let chunkSize = 100
    let chunkCount = 10
    for startIndex in stride(from: 0, to: chunkSize * chunkCount, by: chunkSize) {
      let records = (startIndex..<startIndex + chunkSize).map { TestRecord(objectID: "\($0)") }
      batchRecords.append(contentsOf: records)
      try index.saveObjects(records).wait()
    }
    
    
    let firstObjectsIDs = [objectID, generatedObjectID] + objectsIDs + generatedObjectIDs
    
    let expectedObjects = [object, objectWithGeneratedID] + objects + objectsWithGeneratedID
    let fetchedObjects: [TestRecord] = try index.getObjects(withIDs: firstObjectsIDs).results.compactMap { $0 }
    for (expected, fetched) in zip(expectedObjects, fetchedObjects) {
      XCTAssertEqual(expected, fetched)
    }
        
    var response = try index.browse()
    
    var fetchedRecords: [TestRecord] = try response.extractHits()

    while let cursor = response.cursor {
      response = try index.browse(cursor: cursor)
      fetchedRecords.append(contentsOf: try response.extractHits())
    }
    
    XCTAssertEqual(response.nbHits, 1006)

    let expectedRecords = [object, objectWithGeneratedID] + objects + objectsWithGeneratedID + batchRecords
    
    let edict = Dictionary(grouping: expectedRecords, by: \.objectID!)
    let fdict = Dictionary(grouping: fetchedRecords, by: \.objectID!)
    
    for (key, value) in edict {
      XCTAssertEqual(value, fdict[key])
    }
    
    try index.partialUpdateObject(withID: objectID, with: .update(attribute: "string", value: "partiallyUpdated"), createIfNotExists: false).wait()

    try index.partialUpdateObjects(updates: [(objectsIDs[0], .update(attribute: "string", value: "partiallyUpdated")), (objectsIDs[1], .increment(attribute: "numeric", value: 10))], createIfNotExists: false).wait()
    
    
    let updated: [TestRecord] = try index.getObjects(withIDs: [objectID] + objectsIDs).results.compactMap { $0 }
    
    XCTAssertEqual(updated.first { $0.objectID == objectID }, object.set(\.string, to: "partiallyUpdated"))
    XCTAssertEqual(updated.first { $0.objectID == objectsIDs.first! }, objects.first!.set(\.string, to: "partiallyUpdated"))
    XCTAssertEqual(updated.first { $0.objectID == objectsIDs.last! }, objects.last!.set(\.numeric, to: objects.last!.numeric + 10))
    
    try index.deleteObject(withID: objectID).wait()
    try index.deleteObjects(withIDs: [generatedObjectID] + objectsIDs + generatedObjectIDs).wait()
    try index.clearObjects().wait()
    
    
    response = try index.browse()
    XCTAssertEqual(response.nbHits, 0)
    
  }

  func testSaveGetObject() throws {

    let object: JSON = [
      "testField1": "testValue1",
      "testField2": 2,
      "testField3": true]

    let creation = try index.saveObject(object, autoGeneratingObjectID: true)
    try creation.wait()
    let fetchedObject: JSON = try index.getObject(withID: creation.task.objectID)
    XCTAssertEqual(fetchedObject["testField1"], "testValue1")
    XCTAssertEqual(fetchedObject["testField2"], 2)
    XCTAssertEqual(fetchedObject["testField3"], true)
  }

  func testSaveGetObjectCallback() throws {

    let object: JSON = [
      "testField1": "testValue1",
      "testField2": 2,
      "testField3": true]

    let expectation = self.expectation(description: "Save-Wait-Create")

    index.saveObject(object, autoGeneratingObjectID: true, completion: extract { creation in
      creation.wait(completion: extract { _ in
        self.index.getObject(withID: creation.task.objectID, completion: extract { (fetchedObject: JSON) in
          XCTAssertEqual(fetchedObject["testField1"], "testValue1")
          XCTAssertEqual(fetchedObject["testField2"], 2)
          XCTAssertEqual(fetchedObject["testField3"], true)
          expectation.fulfill()
        })
      })
    })

    waitForExpectations(timeout: expectationTimeout, handler: .none)

  }

}
