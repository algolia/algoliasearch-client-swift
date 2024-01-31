//
//  QueryRulesIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class QueryRulesIntegrationTests: IntegrationTestCase {
  
  override var indexNameSuffix: String? { return "rules" }
  
  override var retryableTests: [() throws -> Void] {
    [queryRules]
  }
  
  func queryRules() throws {
  
    let index = client.index(withName: "rules")
    
    let records: [JSON] = [
      ["objectID": "iphone_7", "brand": "Apple", "model": "7"],
      ["objectID": "iphone_8", "brand": "Apple", "model": "8"],
      ["objectID": "iphone_x", "brand": "Apple", "model": "X"],
      ["objectID": "one_plus_one", "brand": "OnePlus", "model": "One"],
      ["objectID": "one_plus_two", "brand": "OnePlus", "model": "Two"],
    ]
    
    try index.saveObjects(records).wait()
    
    let settings = Settings().set(\.attributesForFaceting, to: [.default("brand"), .default("model")])
    
    try index.setSettings(settings).wait()
    
    let brandAutomaticFacetingRule = Rule(objectID: "brand_automatic_faceting")
      .set(\.isEnabled, to: false)
      .set(\.conditions, to: [.init(anchoring: .is, pattern: .facet("brand"), alternatives: nil)])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.automaticFacetFilters, to: [.init(attribute: "brand", score: 42, isDisjunctive: true)]))
      .set(\.validity, to: [
        .init(from: Date(timeIntervalSince1970: 1532439300), until: Date(timeIntervalSince1970: 1532525700)),
        .init(from: Date(timeIntervalSince1970: 1532612100), until: Date(timeIntervalSince1970: 1532698500)),
      ])
      .set(\.description, to: "Automatic apply the faceting on `brand` if a brand value is found in the query")
    
    
    try index.saveRule(brandAutomaticFacetingRule).wait()
    
    let queryEditsRule = Rule(objectID: "query_edits")
      .set(\.conditions, to: [.init(anchoring: .is, pattern: .literal("mobile phone"), alternatives: .true)])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.filterPromotes, to: false)
        .set(\.queryTextAlteration, to: .edits([
          .remove("mobile"),
          .replace("phone", with: "iphone")])))
    
    let queryPromoRule = Rule(objectID: "query_promo")
      .set(\.consequence, to: Rule.Consequence()
        .set(\.query, to: Query.empty.set(\.filters, to: "brand:OnePlus")))
    
    let queryPromoSummerRule = Rule(objectID: "query_promo_summer")
      .set(\.conditions, to: [Rule.Condition().set(\.context, to: "summer")])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.query, to: Query.empty.set(\.filters, to: "brand:OnePlus")))
    
    let rules = [
      queryEditsRule,
      queryPromoRule,
      queryPromoSummerRule,
    ]
    
    try index.saveRules(rules).wait()
    
    //let response = try index.searchRules(RuleQuery().set(\.context, to: "summer"))
    //TODO: understand why search for rules doesn't work after multi-condition introduction
    //XCTAssertEqual(response.nbHits, 1)
    
    let fetchedBrandAutomaticFacetingRule = try index.getRule(withID: brandAutomaticFacetingRule.objectID)
    try AssertEquallyEncoded(fetchedBrandAutomaticFacetingRule, brandAutomaticFacetingRule)

    let fetchedQueryEditsRule = try index.getRule(withID: queryEditsRule.objectID)
    try AssertEquallyEncoded(fetchedQueryEditsRule, queryEditsRule)

    let fetchedQueryPromoRule = try index.getRule(withID: queryPromoRule.objectID)
    try AssertEquallyEncoded(fetchedQueryPromoRule, queryPromoRule)

    let fetchedQueryPromoSummerRule = try index.getRule(withID: queryPromoSummerRule.objectID)
    try AssertEquallyEncoded(fetchedQueryPromoSummerRule, queryPromoSummerRule)

    let fetchedRules = try index.searchRules("").hits.map(\.rule)
    XCTAssertEqual(fetchedRules.count, 4)
    
    try AssertEquallyEncoded(fetchedRules.first(where: { $0.objectID ==  brandAutomaticFacetingRule.objectID}), brandAutomaticFacetingRule)
    try AssertEquallyEncoded(fetchedRules.first(where: { $0.objectID ==  queryEditsRule.objectID}), queryEditsRule)
    try AssertEquallyEncoded(fetchedRules.first(where: { $0.objectID ==  queryPromoRule.objectID}), queryPromoRule)
    try AssertEquallyEncoded(fetchedRules.first(where: { $0.objectID ==  queryPromoSummerRule.objectID}), queryPromoSummerRule)

    try index.deleteRule(withID: brandAutomaticFacetingRule.objectID).wait()
    try AssertThrowsHTTPError(index.getRule(withID: brandAutomaticFacetingRule.objectID), statusCode: 404)

    try index.clearRules().wait()
    try AssertThrowsHTTPError(index.getRule(withID: queryEditsRule.objectID), statusCode: 404)
    try AssertThrowsHTTPError(index.getRule(withID: queryPromoRule.objectID), statusCode: 404)
    try AssertThrowsHTTPError(index.getRule(withID: queryPromoSummerRule.objectID), statusCode: 404)
    
    XCTAssertEqual(try index.searchRules("").nbHits, 0)
    
  }
  
}
