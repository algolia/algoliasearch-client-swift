//
//  TestRequester.swift
//
//
//  Created by Vladislav Fitc on 01/09/2021.
//

import Foundation

@testable import AlgoliaSearchClient

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class TestRequester: HTTPRequester {
  var onRequest: (URLRequest) -> Void = { _ in }

  func perform<T>(request: URLRequest, completion _: @escaping (Result<T, Error>) -> Void)
    -> TransportTask where T: Decodable
  {
    onRequest(request)
    return MockTask()
  }

  class MockTask: NSObject, TransportTask {
    func cancel() {}

    var progress: Progress {
      .init(totalUnitCount: 0)
    }
  }
}
