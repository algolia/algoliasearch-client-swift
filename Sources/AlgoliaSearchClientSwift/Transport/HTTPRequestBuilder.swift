//
//  HTTPRequestBuilder.swift
//  
//
//  Created by Vladislav Fitc on 08/04/2020.
//

import Foundation

class HTTPRequestBuilder {
  
  let requester: HTTPRequester
  let retryStrategy: RetryStrategy
  let configuration: Configuration
  let credentials: Credentials?
  
  init(requester: HTTPRequester,
       retryStrategy: RetryStrategy,
       configuration: Configuration,
       credentials: Credentials?) {
    self.requester = requester
    self.retryStrategy = retryStrategy
    self.configuration = configuration
    self.credentials = credentials
  }

  func build<T: Codable>(for command: AlgoliaCommand, with completion: @escaping ResultCallback<T>) -> HTTPRequest<T> {
    
    let timeout = command.requestOptions?.timeout(for: command.callType) ?? configuration.timeout(for: command.callType)
    let hostIterator = HostIterator(retryStrategy: retryStrategy, callType: command.callType)
    let request = command.urlRequest.setNotNil(\.credentials, to: credentials)
    
    return HTTPRequest(requester: requester, retryStrategy: retryStrategy, hostIterator: hostIterator, request: request, timeout: timeout, completion: completion)
  }
  
  func build<T: Codable>(for command: AlgoliaCommand, responseType: T.Type) -> HTTPRequest<T> {
    return build(for: command, with: { (_:Result<T, Swift.Error>) in })
  }
  
}
