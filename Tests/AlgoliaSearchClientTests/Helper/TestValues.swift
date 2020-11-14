//
//  TestValues.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
@testable import AlgoliaSearchClient

struct TestValues {
  let indexName: IndexName = "testIndex"
  let anotherIndexName: IndexName = "anotherIndexName"
  let objectID: ObjectID = "testObjectID"
  let objectIDs: [ObjectID] = ["testObjectID1", "testObjectID2"]
  let attribute: Attribute = "testAttribute"
  let attributes: [Attribute] = ["attr1", "attr2"]
  let record: JSON = ["attr": "value"]
  let batchOperations: [BatchOperation] = [.init(action: .addObject, body: ["attr": "value"]), .init(action: .deleteObject, body: ["attr": "value"])]
  let query = Query("testQuery")
    .set(\.page, to: 10)
    .set(\.customParameters, to: ["customKey": "customValue"])
  let settings: Settings = {
    var settings = Settings()
    settings.attributesForFaceting = [.default("attr1"), .filterOnly("attr2"), .searchable("attr3")]
    settings.attributesToHighlight = ["attr1", "attr2"]
    return settings
  }()
  let taskID: TaskID = "testTaskID"
  let requestOptions = RequestOptions(headers: ["testHeader": "testHeaderValue"], urlParameters: ["testParameter": "testParameterValue"])
  let cursor: Cursor = "AgA+Bgg4MTUyNTQ0Mg=="
  let userID: UserID = "testUserID"
  let clusterName: ClusterName = "testClusterName"
  
  var rule: Rule = {
    let condition = Rule.Condition()
      .set(\.anchoring, to: .is)
      .set(\.pattern, to: .facet("attribute"))
      .set(\.context, to: "test context")
      .set(\.alternatives, to: false)
    
    let consequence = Rule.Consequence()
      .set(\.automaticFacetFilters, to: [.init(attribute: "attr1", score: 10, isDisjunctive: true)])
      .set(\.automaticOptionalFacetFilters, to: [.init(attribute: "attr2", score: 20, isDisjunctive: false)])
      .set(\.query, to: Query.empty.set(\.filters, to: "brand:samsung"))
      .set(\.queryTextAlteration, to: .replacement("replacement"))
      .set(\.promote, to: [.init(objectID: "o1", position: 1)])
      .set(\.filterPromotes, to: true)
      .set(\.hide, to: ["o1", "o2"])
      .set(\.userData, to: ["myKey": "myValue"])
    
    let date = Date()
    let timeRange = TimeRange(from: date, until: date.addingTimeInterval(.days(10)))
    
    return Rule(objectID: "testObjectID")
      .set(\.conditions, to: [condition])
      .set(\.consequence, to: consequence)
      .set(\.isEnabled, to: true)
      .set(\.validity, to: [timeRange])
      .set(\.description, to: "test description")
  }()
  
  var synonym: Synonym = {
    Synonym.oneWay(objectID: "testObjectID", input: "", synonyms: [])
  }()
  
  var abTest: ABTest = {
    ABTest(name: "",
           endAt: Date(),
           variantA: .init(
            indexName: "i1",
            trafficPercentage: 10,
            customSearchParameters: Query().set(\.filters, to: "brand:Samsung"),
            description: "test A"
           ),
           variantB: .init(
            indexName: "i1",
            trafficPercentage: 90,
            customSearchParameters: Query().set(\.removeStopWords, to: .queryLanguages([.brunei])),
            description: "test B"
           )
    )
  }()
  
  var personalizationStrategy: PersonalizationStrategy = {
    PersonalizationStrategy(eventsScoring: [.init(eventName: "e1", eventType: .view, score: 10)], facetsScoring: [.init(facetName: "a1", score: 20)], personalizationImpact: 100)
  }()
  
}
