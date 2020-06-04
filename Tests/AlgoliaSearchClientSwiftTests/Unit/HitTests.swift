//
//  HitTests.swift
//  
//
//  Created by Vladislav Fitc on 05/06/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

private struct TestRestaurant: Codable {
  
  let name: String
  let cuisine: [String]
  let contact: Contact
  let is_open: [String]
  let is_booking_required: Bool
  let description: String
  
  struct Address: Codable {
    let country: String
    let postcode: String
    let building: String
    let street: String
    let locality: String
    let town: String
    let county: String
  }
  
  struct Contact: Codable {
    let address: Address
    let website: String
    let telephone: String
  }
  
}

class HitTests: XCTestCase {
  
  func testDecoding() throws {
    
    do {
      
      let hit = try AssertDecode(jsonFilename: "Hit.json", expected: Hit<TestRestaurant>.self)
      
      XCTAssertEqual(hit.objectID, "7236")
      XCTAssertEqual(hit.object.name, "1580")
      XCTAssertEqual(hit.object.cuisine, ["Indian"])
      XCTAssertEqual(hit.object.is_open, ["tuesday",
                                          "wednesday",
                                          "thursday",
                                          "friday",
                                          "saturday",
                                          "sunday"])
      XCTAssertEqual(hit.object.is_booking_required, false)
      XCTAssertEqual(hit.object.description, "An utterly resplendent addition to the Birmingham dining scene, 1580 is an enchanting Indian restaurant awash with a distinctly contemporary style that showcases both the rich culture and the sumptuous fare of India. Speahreaded by a team of master chefs, 1580 offers a truly modern interpretation of Indian cuisine that’s well worth sampling.\n\n \n\nA cornucopia of classic dishes are available, offering traditional palates a divine taste of the cuisine, yet there are also some tantalising specialities to consider. Outstanding examples of such include the sumptuous 1580 Signature Karkat, a whole lobster cooked with a choice of sauce & paired with steam rice, and the delectable Barer Curry, tandoori cooked quail enriched with green chillies, garlic & fresh ginger. An already enticing prospect, dining at 1580 is only enhanced by dining with a hi-life membership thanks to the fantastic discounts it grants.\n")

      
      let rankingInfo = try XCTUnwrap(hit.rankingInfo)
      
      XCTAssertEqual(rankingInfo.typosCount, 0)
      XCTAssertEqual(rankingInfo.firstMatchedWord, 0)
      XCTAssertEqual(rankingInfo.proximityDistance, 0)
      XCTAssertEqual(rankingInfo.userScore, 2092)
      XCTAssertEqual(rankingInfo.geoDistance, 0)
      XCTAssertEqual(rankingInfo.geoPrecision, 0)
      XCTAssertEqual(rankingInfo.exactWordsCount, 0)
      XCTAssertEqual(rankingInfo.words, 0)
      XCTAssertEqual(rankingInfo.filters, 0)
      
      let snippetResult = try XCTUnwrap(hit.snippetResult)
      
      switch snippetResult {
      case .dictionary(let dict):
        let expectedKeys: Set<String> = ["name", "cuisine", "contact", "description", "is_open", "_geoloc"]
        XCTAssertEqual(Set(dict.keys), expectedKeys)
        
        switch dict["contact"] {
        case .dictionary?:
          break
        default:
          XCTFail("Contact snippet must be a dictionary")
        }

      default:
        XCTFail("Snippet result root must be a dictionary")
      }
      
      let highlightResult = try XCTUnwrap(hit.highlightResult)
      
      switch highlightResult {
      case .dictionary(let dict):
        let expectedKeys: Set<String> = ["name", "cuisine", "contact"]
        XCTAssertEqual(Set(dict.keys), expectedKeys)
        
        switch dict["contact"] {
        case .dictionary?:
          break
        default:
          XCTFail("Contact highlight must be a dictionary")
        }
        
      default:
        XCTFail("Highlight result root must be a dictionary")
      }
    
    }
    
  }
  
}
