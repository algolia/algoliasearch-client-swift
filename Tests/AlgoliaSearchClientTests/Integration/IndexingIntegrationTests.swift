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
  
  override var retryableTests: [() throws -> Void] {
    [
      indexing,
      saveGetObject,
      saveGetObjectCallback
    ]
  }
  
  func indexing() throws {
    
    let objectID = ObjectID(rawValue: .init(randomWithLength: 10))
    let object = TestRecord(objectID: objectID)
    
    // Add 1 record with saveObject with an objectID and collect taskID/objectID
    let objectCreation = try index.saveObject(object)
    try objectCreation.wait()
    XCTAssertEqual(objectCreation.task.objectID, objectID)
    
    // Add 1 record with saveObject without an objectID and collect taskID/objectID
    var objectWithGeneratedID = TestRecord()
    let objectWithGeneratedIDCreation = try index.saveObject(objectWithGeneratedID, autoGeneratingObjectID: true)
    try objectWithGeneratedIDCreation.wait()

    let generatedObjectID = objectWithGeneratedIDCreation.task.objectID
    objectWithGeneratedID.objectID = generatedObjectID
            
    // Perform a saveObjects with an empty set of objects and collect taskID
    let emptyObjectsCreation = try index.saveObjects([JSON]())
    try emptyObjectsCreation.wait()
    
    // Add 2 records with saveObjects with an objectID and collect taskID/objectID
    let objectsIDs: [ObjectID] = [.init(rawValue: .init(randomWithLength: 10)), .init(rawValue: .init(randomWithLength: 10))]
    let objects = objectsIDs.map(TestRecord.init)
    let objectsCreation = try index.saveObjects(objects)
    try objectsCreation.wait()

    XCTAssertEqual(objectsCreation.batchesResponse.objectIDs, objectsIDs)
    
    // Add 2 records with saveObjects without an objectID and collect taskID/objectID
    var objectsWithGeneratedID = [TestRecord(), TestRecord()]
    let objectsWithGeneratedIDCreation = try index.saveObjects(objectsWithGeneratedID, autoGeneratingObjectID: true)
    try objectWithGeneratedIDCreation.wait()

    let generatedObjectIDs = objectsWithGeneratedIDCreation.batchesResponse.objectIDs.compactMap { $0 }
    objectsWithGeneratedID = zip(objectsWithGeneratedID, generatedObjectIDs).map { $0.0.set(\.objectID, to: $0.1) }
    
    // Sequentially send 10 batches of 100 objects with objectID from 1 to 1000 with batch and collect taskIDs/objectIDs
    var batchRecords: [TestRecord] = []
    let chunkSize = 100
    let chunkCount = 10
    for startIndex in stride(from: 0, to: chunkSize * chunkCount, by: chunkSize) {
      let records = (startIndex..<startIndex + chunkSize).map { TestRecord(objectID: "\($0)") }
      batchRecords.append(contentsOf: records)
      // Wait for all collected tasks to terminate with waitTask
      try index.saveObjects(records).wait()
    }

    // Retrieve the 6 first records with getObject and check their content against original records
    // Retrieve the 1000 remaining records with getObjects with objectIDs from 1 to 1000 and check their content against original records
    let firstObjectsIDs = [objectID, generatedObjectID] + objectsIDs + generatedObjectIDs
    
    let expectedObjects = [object, objectWithGeneratedID] + objects + objectsWithGeneratedID
    let fetchedObjects: [TestRecord] = try index.getObjects(withIDs: firstObjectsIDs).results.compactMap { $0 }
    for (expected, fetched) in zip(expectedObjects, fetchedObjects) {
      XCTAssertEqual(expected, fetched)
    }
        
    // Browse all records with browseObjects and make sure we have browsed 1006 records, and check that all objectIDs are found
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
    
    // Alter 1 record with partialUpdateObject and collect taskID/objectID
    try index.partialUpdateObject(withID: objectID, with: .update(attribute: "string", value: "partiallyUpdated"), createIfNotExists: false).wait()

    // Alter 2 records with partialUpdateObjects and collect taskID/objectID
    try index.partialUpdateObjects(updates: [(objectsIDs[0], .update(attribute: "string", value: "partiallyUpdated")), (objectsIDs[1], .increment(attribute: "numeric", value: 10))], createIfNotExists: false).wait()
    
    // Wait for all collected tasks to terminate with waitTask
    // Retrieve all the previously altered records with getObject and check their content against the modified records
    let updated: [TestRecord] = try index.getObjects(withIDs: [objectID] + objectsIDs).results.compactMap { $0 }
    
    XCTAssertEqual(updated.first { $0.objectID == objectID }, object.set(\.string, to: "partiallyUpdated"))
    XCTAssertEqual(updated.first { $0.objectID == objectsIDs.first! }, objects.first!.set(\.string, to: "partiallyUpdated"))
    XCTAssertEqual(updated.first { $0.objectID == objectsIDs.last! }, objects.last!.set(\.numeric, to: objects.last!.numeric + 10))
    
    // Add 1 record with saveObject with an objectID and a tag algolia and wait for the task to finish
    let taggedRecord = TestRecord(objectID: "taggedObject").set(\._tags, to: ["algolia"])
    try index.saveObject(taggedRecord).wait()
    
    // Delete the first record with deleteObject and collect taskID
    try index.deleteObject(withID: objectID).wait()
    
    // Delete the record containing the tag algolia with deleteBy and the tagFilters option and collect taskID
    try index.deleteObjects(byQuery: DeleteByQuery().set(\.filters, to: "algolia")).wait()
        
    // Delete the 5 remaining first records with deleteObjects and collect taskID
    try index.deleteObjects(withIDs: [generatedObjectID] + objectsIDs + generatedObjectIDs).wait()
    
    // Delete the 1000 remaining records with clearObjects and collect taskID
    // Wait for all collected tasks to terminate
    try index.clearObjects().wait()
    
    // Browse all objects with browseObjects and make sure that no records are returned
    response = try index.browse()
    XCTAssertEqual(response.nbHits, 0)
    
  }

  func saveGetObject() throws {

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

  func saveGetObjectCallback() throws {

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
