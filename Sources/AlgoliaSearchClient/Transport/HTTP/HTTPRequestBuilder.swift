//
//  HTTPRequestBuilder.swift
//  
//
//  Created by Vladislav Fitc on 08/04/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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

  func build<Response: Decodable, Output>(for command: AlgoliaCommand, transform: @escaping (Response) -> Output, with completion: @escaping (HTTPRequest<Response, Output>.Result) -> Void) -> HTTPRequest<Response, Output> {

    let timeout = command.requestOptions?.timeout(for: command.callType) ?? configuration.timeout(for: command.callType)
    var request = command.urlRequest.setIfNotNil(\.credentials, to: credentials)
    let userAgentsValue = UserAgentController.userAgents.map(\.description).joined(separator: "; ")
    request.addValue(userAgentsValue, forHTTPHeaderField: HTTPHeaderKey.userAgent.rawValue)
    return HTTPRequest(requester: requester,
                       retryStrategy: retryStrategy,
                       request: request,
                       callType: command.callType,
                       timeout: timeout,
                       transform: transform,
                       completion: completion)
  }

  func build<Response: Decodable, Output>(for command: AlgoliaCommand, transform: @escaping (Response) -> Output, responseType: Output.Type) -> HTTPRequest<Response, Output> {
    return build(for: command,
                 transform: transform,
                 with: { (_:HTTPRequest<Response, Output>.Result) in })
  }

}
