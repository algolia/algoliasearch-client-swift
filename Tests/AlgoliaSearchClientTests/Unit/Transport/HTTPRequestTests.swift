//
//  HTTPRequestTests.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private extension URL {
  static var template = URL(string: "www.algolia.com")!
}

class HTTPRequestTests: XCTestCase {
  
  class TestRequester: HTTPRequester {
    
    var count = 0
    
    func perform<T>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> TransportTask where T : Decodable {
      count += 1
      switch count {
      case 1:
        completion(.failure(TransportError.requestError(URLError(.timedOut))))
      case 2:
        completion(.failure(TransportError.httpError(HTTPError(statusCode: 503, message: nil))))
      case 3:
        completion(.failure(TransportError.requestError(URLError(.cannotLoadFromNetwork))))
      case 4:
        completion(.failure(TransportError.requestError(URLError(.backgroundSessionWasDisconnected))))
      default:
        break
      }
      return URLSession.shared.dataTask(with: .template)
    }
        
    
  }
  
  func testRetry() {
    let requester = TestRequester()
    let hosts = (1...3).map { RetryableHost(url: URL(string: "algolia\($0).com")!, callType: .read) }
    let retryStrategy = AlgoliaRetryStrategy(hosts: hosts)
    let hostIterator = retryStrategy.retryableHosts(for: .read)
    let exp = expectation(description: "Request completed")
    let request = HTTPRequest(requester: requester,
                              retryStrategy: retryStrategy,
                              hostIterator: hostIterator,
                              request: URLRequest(url: URL(string: "/1/test/")!),
                              callType: .read,
                              timeout: 10) { (result: Result<String, Error>) in
      if case .failure(TransportError.noReachableHosts(intermediateErrors: let errors)) = result {
        for (index, error) in errors.enumerated() {
          switch (index, error) {
          case (0, TransportError.requestError(URLError.timedOut)):
            break
          case (1, TransportError.httpError(let httpError)) where httpError.statusCode == 503:
            break
          case (2, TransportError.requestError(URLError.cannotLoadFromNetwork)):
            break
          case (3, TransportError.requestError(URLError.backgroundSessionWasDisconnected)):
            break
          default:
            XCTFail("Unexpected error at index \(index): \(error.localizedDescription)")
          }
        }
      } else {
        XCTFail("Unexpected success result")
      }
      exp.fulfill()
    }
    OperationQueue.main.addOperation(request)
    waitForExpectations(timeout: 3, handler: nil)
  }
  
}
