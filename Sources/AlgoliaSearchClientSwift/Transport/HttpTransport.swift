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
  let operationLauncher: OperationLauncher
  let configuration: Configuration
  let credentials: Credentials?
  var retryStrategy: RetryStrategy
  
  init(requester: HTTPRequester, configuration: Configuration, operationLauncher: OperationLauncher, retryStrategy: RetryStrategy, credentials: Credentials) {
    self.requester = requester
    self.configuration = configuration
    self.operationLauncher = operationLauncher
    self.retryStrategy = retryStrategy
    self.credentials = credentials
  }
  
  func execute<T: Codable>(_ command: AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation & TransportTask {
    let request = HTTPRequestBuilder(requester: requester, configuration: configuration, credentials: credentials, command: command, retryStrategyContainer: self, completion: completion).build()
    return operationLauncher.launch(request)
  }
  
  func execute<T: Codable>(_ command: AlgoliaCommand) throws -> T {
    let request = HTTPRequestBuilder<T>(requester: requester, configuration: configuration, credentials: credentials, command: command, retryStrategyContainer: self, completion: { _ in }).build()
    return try operationLauncher.launchSync(request)
  }
  
  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    return operationLauncher.launch(operation)
  }
  
  func launch<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    return try operationLauncher.launchSync(operation)
  }

}

class HTTPRequestBuilder<T: Codable> {
  
  let requester: HTTPRequester
  let configuration: Configuration
  let credentials: Credentials?
  let command: AlgoliaCommand
  let retryStrategyContainer: RetryStrategyContainer
  let completion: ResultCallback<T>
  
  init(requester: HTTPRequester,
       configuration: Configuration,
       credentials: Credentials?,
       command: AlgoliaCommand,
       retryStrategyContainer: RetryStrategyContainer,
       completion: @escaping ResultCallback<T>) {
    self.requester = requester
    self.configuration = configuration
    self.credentials = credentials
    self.command = command
    self.retryStrategyContainer = retryStrategyContainer
    self.completion = completion
  }

  func build() -> HTTPRequest<T> {
    
    let timeout = command.requestOptions?.timeout(for: command.callType) ?? configuration.timeout(for: command.callType)
    let hostIterator = HostIterator(container: retryStrategyContainer, callType: command.callType)
    let request = command.urlRequest.setNotNil(\.credentials, to: credentials)
    
    return HTTPRequest(requester: requester, retryStrategyContainer: retryStrategyContainer, hostIterator: hostIterator, request: request, timeout: timeout, completion: completion)
  }
  
}
