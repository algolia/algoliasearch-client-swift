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
  
  func testBasic() {
    let input = "Woodstock is <em>Snoopy</em>'s friend"
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, "Woodstock is Snoopy's friend")
    XCTAssertEqual(taggedString.taggedSubstrings(), ["Snoopy"])
    XCTAssertEqual(taggedString.untaggedSubstrings(), ["Woodstock is ", "'s friend"])
  }
  
  func testMultipleHighlighted() {
    
    let input = "<em>Live</em> as <em>if you were</em> to die <em>tomorrow</em>. Learn as if you were to live <em>forever</em>"
    
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, "Live as if you were to die tomorrow. Learn as if you were to live forever")
    
    let expectedTaggedSubstrings: [Substring] = [
      "Live",
      "if you were",
      "tomorrow",
      "forever",
    ]
    
    XCTAssertEqual(expectedTaggedSubstrings, taggedString.taggedSubstrings())
    
    let expectedUntaggedSubstrings: [Substring] = [
      " as ",
      " to die ",
      ". Learn as if you were to live ",
    ]
    XCTAssertEqual(expectedUntaggedSubstrings, taggedString.untaggedSubstrings())
    
  }
  
  func testWholeStringHighlighted() {
    let input = "<em>Highlighted string</em>"
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag, options: [.caseInsensitive])
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, "Highlighted string")
    XCTAssertEqual(taggedString.taggedSubstrings(), ["Highlighted string"])
    XCTAssertTrue(taggedString.untaggedSubstrings().isEmpty)
  }
  
  func testNoHighlighted() {
    let input = "Just a string"
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag, options: [.caseInsensitive])
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, input)
    XCTAssertTrue(taggedString.taggedRanges.isEmpty)
    XCTAssertEqual(taggedString.untaggedSubstrings(), [Substring(input)])
  }
  
  func testEmpty() {
    let input = ""
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag, options: [.caseInsensitive])
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, input)
    XCTAssertTrue(taggedString.taggedRanges.isEmpty)
    XCTAssertEqual(taggedString.untaggedSubstrings(), [""])
  }
  
  func testWithDecodedString() throws {

    let expectedHighlightedPart: Substring = "rennais"
    
    let inlineString = "VIDÉO. Des CRS déployés devant un lycée <em>rennais</em> pour les épreuves anticipées du bac"

    let stringData = try Data(filename: "HighlightedString.json")
    let decodedString = try XCTUnwrap(String(data: stringData, encoding: .utf8))
        
    var inlineHiglighted = TaggedString(string: inlineString, preTag: preTag, postTag: postTag)
    var decodedHighlighted = TaggedString(string: decodedString, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual([expectedHighlightedPart], inlineHiglighted.taggedSubstrings())
    XCTAssertEqual([expectedHighlightedPart], decodedHighlighted.taggedSubstrings())
  }
  
  func testNested() throws {
    let input = "Your time is limited, <em>so don't waste it living <em>someone else's life</em>. Don't be trapped by dogma – </em>which is living with the results of other people's thinking."
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, "Your time is limited, so don't waste it living someone else's life. Don't be trapped by dogma – which is living with the results of other people's thinking.")
    XCTAssertEqual(taggedString.taggedSubstrings(), ["so don't waste it living someone else's life. Don't be trapped by dogma – "])
    XCTAssertEqual(taggedString.untaggedSubstrings(), ["Your time is limited, ", "which is living with the results of other people's thinking."])
  }
  
  func testNestedFollowing() throws {
    let input = "Your time is limited, <em><em>so don't waste it living someone else's life</em></em>. Don't be trapped by dogma – which is living with the results of other people's thinking."
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, "Your time is limited, so don't waste it living someone else's life. Don't be trapped by dogma – which is living with the results of other people's thinking.")
    XCTAssertEqual(taggedString.taggedSubstrings(), ["so don't waste it living someone else's life"])
    XCTAssertEqual(taggedString.untaggedSubstrings(), ["Your time is limited, ", ". Don't be trapped by dogma – which is living with the results of other people's thinking."])
  }
  
  func testExtraOpenTag() throws {
    let input = "Your time is limited, <em>so don't waste it living <em>someone else's life. Don't be trapped by dogma – </em>which is living with the results of other people's thinking."
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, "Your time is limited, so don't waste it living someone else's life. Don't be trapped by dogma – which is living with the results of other people's thinking.")
    XCTAssertEqual(taggedString.taggedSubstrings(), ["someone else's life. Don't be trapped by dogma – "])
    XCTAssertEqual(taggedString.untaggedSubstrings(), ["Your time is limited, so don't waste it living ", "which is living with the results of other people's thinking."])
  }
  
  func testExtraClosingTag() throws {
    let input = "Your time is limited, <em>so don't waste it living someone else's life.</em> Don't be trapped by dogma – </em>which is living with the results of other people's thinking."
    var taggedString = TaggedString(string: input, preTag: preTag, postTag: postTag)
    
    XCTAssertEqual(taggedString.input, input)
    XCTAssertEqual(taggedString.output, "Your time is limited, so don't waste it living someone else's life. Don't be trapped by dogma – which is living with the results of other people's thinking.")
    XCTAssertEqual(taggedString.taggedSubstrings(), ["so don't waste it living someone else's life."])
    XCTAssertEqual(taggedString.untaggedSubstrings(), ["Your time is limited, ", " Don't be trapped by dogma – which is living with the results of other people's thinking."])
  }
  
}
