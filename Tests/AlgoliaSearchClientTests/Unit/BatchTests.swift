import Foundation
import XCTest

@testable import AlgoliaSearchClient

class BatchTests: XCTestCase {
  struct Test: Codable, Equatable {
    let attr: String
  }

  func testCoding() throws {
    let object: JSON = ["attr": ["value": 2.5]] as JSON
    let objectID: ObjectID = "objectID"
    try AssertEncodeDecode(
      BatchOperation.add(ObjectWrapper(objectID: objectID, object: object)),
      ["action": "addObject", "body": ["objectID": "objectID", "attr": ["value": 2.5]]])
    try AssertEncodeDecode(
      BatchOperation.update(objectID: objectID, object),
      ["action": "updateObject", "body": ["objectID": "objectID", "attr": ["value": 2.5]]])
    try AssertEncodeDecode(
      BatchOperation.partialUpdate(objectID: objectID, object, createIfNotExists: true),
      ["action": "partialUpdateObject", "body": ["objectID": "objectID", "attr": ["value": 2.5]]])
    try AssertEncodeDecode(
      BatchOperation.partialUpdate(objectID: objectID, object, createIfNotExists: false),
      [
        "action": "partialUpdateObjectNoCreate",
        "body": ["objectID": "objectID", "attr": ["value": 2.5]],
      ])
    try AssertEncodeDecode(
      BatchOperation.delete(objectID: objectID),
      ["action": "deleteObject", "body": ["objectID": "objectID"]])
    try AssertEncodeDecode(BatchOperation.delete, ["action": "delete"])
    try AssertEncodeDecode(BatchOperation.clear, ["action": "clear"])
  }

  func testIndexCoding() throws {
    let object: JSON = ["attr": ["value": 2.5]] as JSON
    try AssertEncodeDecode(
      IndexBatchOperation(
        indexName: "index", operation: .add(object, autoGeneratingObjectID: true)),
      ["indexName": "index", "action": "addObject", "body": ["attr": ["value": 2.5]]])
  }
}
