//
//  HttpTransport.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

/**
 The transport layer is responsible of the serialization/deserialization and the retry strategy.
*/
class HttpTransport: Transport, RetryStrategyContainer {

  let requester: HTTPRequester
  var configuration: Configuration
  var retryStrategy: RetryStrategy
  let credentials: Credentials?

  init(requester: HTTPRequester,
       configuration: Configuration,
       credentials: Credentials? = nil,
       retryStrategy: RetryStrategy? = nil) {
    self.requester = requester
    self.configuration = configuration
    self.credentials = credentials
    self.retryStrategy = retryStrategy ?? AlgoliaRetryStrategy(configuration: configuration)
  }

  func request<T: Codable>(request: URLRequest,
                           callType: CallType,
                           requestOptions: RequestOptions?,
                           completion: @escaping ResultCallback<T>) {
    let hostIterator = HostIterator(container: self, callType: callType)
    var effectiveRequest = request
    effectiveRequest.timeoutInterval = requestOptions?.timeout(for: callType) ?? configuration.timeout(for: callType)
    if let credentials = credentials {
      effectiveRequest.set(credentials)
    }
    self.request(effectiveRequest, hostIterator: hostIterator, requestOptions: requestOptions, completion: completion)
  }

  private func request<T: Codable>(_ request: URLRequest,
                                   hostIterator: HostIterator,
                                   requestOptions: RequestOptions?,
                                   completion: @escaping ResultCallback<T>) {

    guard let host = hostIterator.next() else {
      completion(.failure(Error.noReachableHosts))
      return
    }

    let effectiveRequest = request.withHost(host, requestOptions: requestOptions)

    Logger.info("Perform: \(effectiveRequest.url!)")

    requester.perform(request: effectiveRequest) { [weak self] (result: Result<T, Swift.Error>) in
      guard let transport = self else { return }

      do {
        let retryOutcome = try transport.retryStrategy.notify(host: host, result: result)

        switch retryOutcome {
        case .success:
          completion(result)

        case .retry:
          transport.request(request, hostIterator: hostIterator, requestOptions: requestOptions, completion: completion)
        }
      } catch let error {
        completion(.failure(error))
      }
    }

  }

}
