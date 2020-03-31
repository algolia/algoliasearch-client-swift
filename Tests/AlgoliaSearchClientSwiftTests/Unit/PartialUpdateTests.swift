import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class PartialUpdateTests: XCTestCase {
  
  func testCoding() throws {
    try AssertEncodeDecode(PartialUpdate.add(attribute: "attr", value: 2.5, unique: true), ["attr": ["value": 2.5, "_operation": "AddUnique"]])
    try AssertEncodeDecode(PartialUpdate.add(attribute: "attr", value: "stringValue", unique: true), ["attr": ["value": "stringValue", "_operation": "AddUnique"]])
    try AssertEncodeDecode(PartialUpdate.add(attribute: "attr", value: 2.5, unique: false), ["attr": ["value": 2.5, "_operation": "Add"]])
    try AssertEncodeDecode(PartialUpdate.add(attribute: "attr", value: "stringValue", unique: false), ["attr": ["value": "stringValue", "_operation": "Add"]])
    try AssertEncodeDecode(PartialUpdate.remove(attribute: "attr", value: 2.5), ["attr": ["value": 2.5, "_operation": "Remove"]])
    try AssertEncodeDecode(PartialUpdate.remove(attribute: "attr", value: "stringValue"),["attr": ["value": "stringValue", "_operation": "Remove"]])
    try AssertEncodeDecode(PartialUpdate.increment(attribute: "attr", value: 2.5), ["attr": ["value": 2.5, "_operation": "Increment"]])
    try AssertEncodeDecode(PartialUpdate.decrement(attribute: "attr", value: 2.5), ["attr": ["value": 2.5, "_operation": "Decrement"]])
    try AssertEncodeDecode(PartialUpdate.update(attribute: "attr", value: "string"),["attr": ["value": "string"]])
    try AssertEncodeDecode(PartialUpdate.update(attribute: "attr", value: 2.5), ["attr": ["value": 2.5]])
    try AssertEncodeDecode(PartialUpdate.update(attribute: "attr", value: true), ["attr": ["value": true]])
    try AssertEncodeDecode(PartialUpdate.update(attribute: "attr", value: ["a", "b", "c"]), ["attr": ["value": ["a", "b", "c"]]])
    try AssertEncodeDecode(PartialUpdate.update(attribute: "attr", value: ["a": 1, "b": "s", "c": false]),["attr": ["value": ["a": 1, "b": "s", "c": false]]])
  }
  
}

