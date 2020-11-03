//
//  TaggedStringTests.swift
//  
//
//  Created by Vladislav Fitc on 05/06/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class TaggedStringTests: XCTestCase {
  
  let preTag = "<em>"
  let postTag = "</em>"
  
  func test() {
    let input = "Woodstock is <em>Snoopy</em>'s friend"
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual(taggedString.output, "Woodstock is Snoopy's friend")
    let taggedSubstrings = taggedString.taggedRanges.map { taggedString.output[$0] }
    XCTAssertEqual(taggedSubstrings, ["Snoopy"])
    let untaggedSubstrings = taggedString.untaggedRanges.map { taggedString.output[$0] }
    XCTAssertEqual(untaggedSubstrings, ["Woodstock is ", "'s friend"])
  }
  
  func testMultipleHighlighted() {
    
    let input = "<em>Live</em> as <em>if you were</em> to die <em>tomorrow</em>. Learn as if you were to live <em>forever</em>"
    
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual(taggedString.output, "Live as if you were to die tomorrow. Learn as if you were to live forever")
    
    let expectedTaggedSubstrings = [
      "Live",
      "if you were",
      "tomorrow",
      "forever",
    ]
    let taggedSubstrings = taggedString.taggedRanges.map { String(taggedString.output[$0]) }
    
    XCTAssertEqual(expectedTaggedSubstrings, taggedSubstrings)
    
    let expectedUntaggedSubstrings = [
      " as ",
      " to die ",
      ". Learn as if you were to live ",
    ]
    let untaggedSubstrings = taggedString.untaggedRanges.map {
      String(taggedString.output[$0])
    }
    XCTAssertEqual(expectedUntaggedSubstrings, untaggedSubstrings)
    
  }
  
  func testWholeStringHighlighted() {
    let input = "<em>Highlighted string</em>"
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag, options: [.caseInsensitive])
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, "Highlighted string")
    XCTAssertEqual(taggedString.taggedRanges.map { String(taggedString.output[$0]) }, ["Highlighted string"])
    XCTAssertTrue(taggedString.untaggedRanges.map { String(taggedString.output[$0]) }.isEmpty)
  }
  
  func testNoHighlighted() {
    let input = "Just a string"
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag, options: [.caseInsensitive])
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, input)
    XCTAssertTrue(taggedString.taggedRanges.isEmpty)
    XCTAssertEqual(taggedString.untaggedRanges.map { String(taggedString.output[$0]) }, [input])
  }
  
  func testEmpty() {
    let input = ""
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag, options: [.caseInsensitive])
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, input)
    XCTAssertTrue(taggedString.taggedRanges.isEmpty)
    XCTAssertTrue(taggedString.untaggedRanges.isEmpty)
  }
  
  func testWithDecodedString() throws {

    let expectedHighlightedPart = "rennais"
    
    let inlineString = "VIDÉO. Des CRS déployés devant un lycée <em>rennais</em> pour les épreuves anticipées du bac"

    let stringData = try Data(filename: "HighlightedString.json")
    let decodedString = try XCTUnwrap(String(data: stringData, encoding: .utf8))
    
    let inlineHiglighted = TaggedString(string: inlineString, preTag: "<em>", postTag: "</em>")
    let decodedHighlighted = TaggedString(string: decodedString, preTag: "<em>", postTag: "</em>")
    
    func extractHighlightedPart(from title: TaggedString) -> String {
      var title = title
      let highlightedRange = title.taggedRanges.first!
      let highlightedPart = title.output[highlightedRange]
      return String(highlightedPart)
    }
    
    XCTAssertEqual(expectedHighlightedPart, extractHighlightedPart(from: inlineHiglighted))
    XCTAssertEqual(expectedHighlightedPart, extractHighlightedPart(from: decodedHighlighted))

  }
  
  func testLaziness() throws {
    // This test will provoke runtime error, if the calculation of untagged ranges is not lazy
    let rawString = "a<em><em>b</em></em>c"
    var _ = TaggedString(string: rawString, preTag: "<em>", postTag: "</em>")
  }

}
