import Foundation
import XCTest
@testable import AlgoliaSearchClient

class SynonymTests: XCTestCase {
  
  func testCoding() throws {
    try AssertEncodeDecode(Synonym.multiWay(objectID: "testObjectID", synonyms: ["s1", "s2", "s3"]), ["objectID": "testObjectID", "synonyms": ["s1", "s2", "s3"], "type": "synonym"])
    try AssertEncodeDecode(Synonym.oneWay(objectID: "testObjectID", input: "i1", synonyms: ["s1", "s2", "s3"]), ["objectID": "testObjectID", "input": "i1", "synonyms": ["s1", "s2", "s3"], "type": "oneWaySynonym"])
    try AssertEncodeDecode(Synonym.alternativeCorrection(objectID: "testObjectID", word: "w", corrections: ["c1", "c2", "c3"], typo: .one), ["objectID": "testObjectID", "word": "w", "corrections": ["c1", "c2", "c3"], "type": "altCorrection1"])
    try AssertEncodeDecode(Synonym.alternativeCorrection(objectID: "testObjectID", word: "w", corrections: ["c1", "c2", "c3"], typo: .two), ["objectID": "testObjectID", "word": "w", "corrections": ["c1", "c2", "c3"], "type": "altCorrection2"])
    try AssertEncodeDecode(Synonym.placeholder(objectID: "testObjectID", placeholder: "p", replacements: ["r1", "r2", "r3"]), ["objectID": "testObjectID", "placeholder": "p", "replacements": ["r1", "r2", "r3"], "type": "placeholder"])
  }
  
}


