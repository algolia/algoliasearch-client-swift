import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class BatchTests: XCTestCase {
  
  struct Test: Codable, Equatable {
    let attr: String
  }
  
  func testCoding() throws {
    let object: JSON = ["attr": ["value": 2.5]] as JSON
    let objectID: ObjectID = "objectID"
    try AssertEncodeDecode(BatchOperation.add(object), ["action": "addObject", "body": ["attr": ["value": 2.5]]])
    try AssertEncodeDecode(BatchOperation.update(objectID: objectID, object), ["action": "updateObject", "body": ["objectID": "objectID", "attr": ["value": 2.5]]])
    try AssertEncodeDecode(BatchOperation.partialUpdate(objectID: objectID, object, createIfNotExists: true), ["action": "partialUpdateObject", "body": ["objectID": "objectID", "attr": ["value": 2.5]]])
    try AssertEncodeDecode(BatchOperation.partialUpdate(objectID: objectID, object, createIfNotExists: false), ["action": "partialUpdateObjectNoCreate", "body": ["objectID": "objectID", "attr": ["value": 2.5]]])
    try AssertEncodeDecode(BatchOperation.delete(objectID: objectID), ["action": "deleteObject", "body": ["objectID": "objectID"]])
  }
  
}

