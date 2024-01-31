//
//  TestRequester.swift
//  
//
//  Created by Vladislav Fitc on 01/09/2021.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import AlgoliaSearchClient

class TestRequester: HTTPRequester {
  
  var onRequest: (URLRequest) -> Void = { _ in }
  
  func perform<T>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> TransportTask where T : Decodable {
    onRequest(request)
    return MockTask()
  }
  
  class MockTask: NSObject, TransportTask {
    
    func cancel() {}
    
    var progress: Progress {
      return .init(totalUnitCount: 0)
    }
  }
  
}
