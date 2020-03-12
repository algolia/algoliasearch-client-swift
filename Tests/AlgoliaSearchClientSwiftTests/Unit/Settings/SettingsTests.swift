//
//  SettingsTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SettingsTests: XCTestCase {
  
  func testHome() {
    var settings = Settings()
    settings.attributesForFaceting = [.default("attr1"), .filterOnly("attr2"), .searchable("attr3")]
    settings.sortFacetsBy = .count
    settings.attributesToHighlight = ["attr2", "attr3"]
    print(settings)
  }
  
  func testDecoding() {
    
    let jsonString = """
    {
      "minWordSizefor1Typo": 4,
      "minWordSizefor2Typos": 8,
      "hitsPerPage": 20,
      "maxValuesPerFacet": 100,
      "searchableAttributes": [
        "title",
        "description",
        "author_name"
      ],
      "numericAttributesToIndex": null,
      "attributesToRetrieve": null,
      "unretrievableAttributes": null,
      "optionalWords": null,
      "attributesForFaceting": null,
      "attributesToSnippet": null,
      "attributesToHighlight": null,
      "paginationLimitedTo": 1000,
      "attributeForDistinct": null,
      "exactOnSingleWordQuery": "attribute",
      "ranking": [
        "typo",
        "geo",
        "words",
        "filters",
        "proximity",
        "attribute",
        "exact",
        "custom"
      ],
      "customRanking": null,
      "separatorsToIndex": "",
      "removeWordsIfNoResults": "none",
      "queryType": "prefixLast",
      "highlightPreTag": "<em>",
      "highlightPostTag": "</em>",
      "snippetEllipsisText": "",
      "alternativesAsExact": [
        "ignorePlurals",
        "singleWordSynonym"
      ]
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    do {
      _ = try decoder.decode(Settings.self, from: data)
    } catch let error {
      XCTFail("\(error)")
    }
    
  }
  
}
