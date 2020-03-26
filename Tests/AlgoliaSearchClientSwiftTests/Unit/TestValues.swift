//
//  TestValues.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
@testable import AlgoliaSearchClientSwift

struct TestValues {
  let indexName: IndexName = "testIndex"
  let objectID: ObjectID = "testObjectID"
  let attributes: [Attribute] = ["attr1", "attr2"]
  let record: JSON = ["attr": "value"]
  let batchOperations: [BatchOperation<JSON>] = [.init(action: .addObject, body: ["attr": "value"]), .init(action: .deleteObject, body: ["attr": "value"])]
  let query: Query = {
    var query = Query(stringLiteral: "testQuery")
    query.page = 10
    return query
  }()
  let settings: Settings = {
    var settings = Settings()
    settings.attributesForFaceting = [.default("attr1"), .filterOnly("attr2"), .searchable("attr3")]
    settings.attributesToHighlight = ["attr1", "attr2"]
    return settings
  }()
  let taskID: TaskID = "testTaskID"
  let requestOptions = RequestOptions(headers: ["testHeader": "testHeaderValue"], urlParameters: ["testParameter": "testParameterValue"])
}
