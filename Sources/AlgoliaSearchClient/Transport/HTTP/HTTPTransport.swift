//
//  HTTPTransport.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

/**
 The transport layer is responsible of the serialization/deserialization and the retry strategy.
*/
class HTTPTransport: Transport {

  var applicationID: ApplicationID {
    return credentials.applicationID
  }

  var apiKey: APIKey {
    return credentials.apiKey
  }

  let requestBuilder: HTTPRequestBuilder
  let operationLauncher: OperationLauncher
  let credentials: Credentials

  init(requestBuilder: HTTPRequestBuilder, operationLauncher: OperationLauncher, credentials: Credentials) {
    self.requestBuilder = requestBuilder
    self.operationLauncher = operationLauncher
    self.credentials = credentials
  }

  convenience init(requester: HTTPRequester, configuration: Configuration, retryStrategy: RetryStrategy, credentials: Credentials, operationLauncher: OperationLauncher) {
    let requestBuilder = HTTPRequestBuilder(requester: requester, retryStrategy: retryStrategy, configuration: configuration, credentials: credentials)
    self.init(requestBuilder: requestBuilder, operationLauncher: operationLauncher, credentials: credentials)
  }

  func execute<Response: Decodable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output, completion: @escaping (Result<Output, Swift.Error>) -> Void) -> Operation & TransportTask {
    let request = requestBuilder.build(for: command, transform: transform, with: completion)
    return operationLauncher.launch(request)
  }

  func execute<Response: Decodable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output) throws -> Output {
    let request = requestBuilder.build(for: command, transform: transform, responseType: Output.self)
    return try operationLauncher.launchSync(request)
  }

  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    return operationLauncher.launch(operation)
  }

  func launch<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    return try operationLauncher.launchSync(operation)
  }

}
