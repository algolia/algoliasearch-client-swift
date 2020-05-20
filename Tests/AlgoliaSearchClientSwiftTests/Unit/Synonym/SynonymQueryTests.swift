import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SynonymQueryTests: XCTestCase {
  
  func testCoding() throws {
    try AssertEncodeDecode(SynonymQuery().set(\.query, to: "query").set(\.page, to: 1).set(\.hitsPerPage, to: 10).set(\.synonymTypes, to: [.oneWay, .multiWay]), ["query": "query", "page": 1, "hitsPerPage": 10, "type": "oneWaySynonym,synonym"])
    try AssertEncodeDecode(SynonymQuery().set(\.query, to: "query"), ["query": "query"])
  }
  
}

