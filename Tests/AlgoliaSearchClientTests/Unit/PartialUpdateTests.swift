import Foundation
import XCTest

@testable import AlgoliaSearchClient

class PartialUpdateTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(
      PartialUpdate.add(attribute: "attr", value: 2.5, unique: true),
      ["attr": ["value": 2.5, "_operation": "AddUnique"]])
    try AssertEncodeDecode(
      PartialUpdate.add(attribute: "attr", value: "stringValue", unique: true),
      ["attr": ["value": "stringValue", "_operation": "AddUnique"]])
    try AssertEncodeDecode(
      PartialUpdate.add(attribute: "attr", value: 2.5, unique: false),
      ["attr": ["value": 2.5, "_operation": "Add"]])
    try AssertEncodeDecode(
      PartialUpdate.add(attribute: "attr", value: "stringValue", unique: false),
      ["attr": ["value": "stringValue", "_operation": "Add"]])
    try AssertEncodeDecode(
      PartialUpdate.remove(attribute: "attr", value: 2.5),
      ["attr": ["value": 2.5, "_operation": "Remove"]])
    try AssertEncodeDecode(
      PartialUpdate.remove(attribute: "attr", value: "stringValue"),
      ["attr": ["value": "stringValue", "_operation": "Remove"]])
    try AssertEncodeDecode(
      PartialUpdate.increment(attribute: "attr", value: 2.5),
      ["attr": ["value": 2.5, "_operation": "Increment"]])
    try AssertEncodeDecode(
      PartialUpdate.incrementFrom(attribute: "attr", value: 2),
      ["attr": ["value": 2, "_operation": "IncrementFrom"]])
    try AssertEncodeDecode(
      PartialUpdate.incrementSet(attribute: "attr", value: 2),
      ["attr": ["value": 2, "_operation": "IncrementSet"]])
    try AssertEncodeDecode(
      PartialUpdate.decrement(attribute: "attr", value: 2.5),
      ["attr": ["value": 2.5, "_operation": "Decrement"]])
    try AssertEncodeDecode(
      PartialUpdate.update(attribute: "attr", value: "string"), ["attr": "string"])
    try AssertEncodeDecode(PartialUpdate.update(attribute: "attr", value: 2.5), ["attr": 2.5])
    try AssertEncodeDecode(PartialUpdate.update(attribute: "attr", value: true), ["attr": true])
    try AssertEncodeDecode(
      PartialUpdate.update(attribute: "attr", value: ["a", "b", "c"]), ["attr": ["a", "b", "c"]])
    try AssertEncodeDecode(
      PartialUpdate.update(attribute: "attr", value: ["a": 1, "b": "s", "c": false]),
      ["attr": ["a": 1, "b": "s", "c": false]])
    try AssertEncodeDecode(
      [
        "name": "DIFFERENT",
        "tweetsCount": 2000,
        "followers": .add(value: "username4", unique: false),
        "followersCount": .increment(value: 20),
        "likes": .incrementSet(value: 15),
      ] as PartialUpdate,
      [
        "name": "DIFFERENT",
        "tweetsCount": 2000,
        "followers": ["_operation": "Add", "value": "username4"],
        "followersCount": ["_operation": "Increment", "value": 20],
        "likes": ["_operation": "IncrementSet", "value": 15],
      ])
  }
}
