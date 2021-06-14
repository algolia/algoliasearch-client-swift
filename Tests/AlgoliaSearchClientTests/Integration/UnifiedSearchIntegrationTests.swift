//
//  UnifiedSearchIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2021.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class UnifiedSearchIntegrationTests: IntegrationTestCase {
    
  func testUnifiedSearch() {
    let client = SearchClient(appID: "latency", apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db")
    
    let q1 = IndexedQuery(indexName: "instant_search", query: "smartphone")
    let q2 = IndexedQuery(indexName: "instant_search", query: "smartphone", attribute: "brand", facetQuery: "a")
    
    let exp = expectation(description: "exp")
    
    client.multipleUniQueries(queries: [q1, q2]) { result in
      switch result {
      case .success(let json):
        print(json)
      case .failure(let error):
        print(error)
      }
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)

  }
  
}

struct Queries: AlgoliaCommand {

  let method: HTTPMethod = .post
  let callType: CallType = .read
  let path: MultiIndexCompletion
  let body: Data?
  let requestOptions: RequestOptions?
  
  
  
//  enum Query: Encodable {
//    case def(IndexedQuery)
//    case sffv(IndexName, Attribute, String, AlgoliaSearchClient.Query?)
//
//    func encode(to encoder: Encoder) throws {
//      switch self {
//      case .def(let query):
//        try query.encode(to: encoder)
//
//      case .sffv(let indexName, let attribute, let facetQuery, let query):
//        var parameters = query?.customParameters ?? [:]
//        parameters["facetQuery"] = .init(facetQuery)
//        var effectiveQuery = query ?? .init()
//        effectiveQuery.customParameters = parameters
//        self.body = ParamsWrapper(effectiveQuery.urlEncodedString).httpBody
//      }
//    }
//
//  }
  
  struct Request: Encodable {
    let requests: [Query]
    let strategy: MultipleQueriesStrategy
    
    enum CodingKeys: String, CodingKey {
      case requests
      case strategy
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(requests, forKey: .requests)
      try container.encodeIfPresent(strategy, forKey: .strategy)
    }
  }

//  init(indexName: IndexName, queries: [Query], strategy: MultipleQueriesStrategy = .none, requestOptions: RequestOptions?) {
//    let queries = queries.map { IndexedQuery(indexName: indexName, query: $0) }
//    self.init(queries: queries, strategy: strategy, requestOptions: requestOptions)
//  }

  init(request: Request, requestOptions: RequestOptions?) {
    self.requestOptions = requestOptions
    self.body = request.httpBody
    self.path = (.indexesV1 >>> .multiIndex >>> .queries)
  }
  
  

}
