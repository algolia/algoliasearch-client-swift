//
//  Index.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct Index: Credentials {

  public let name: IndexName
  let transport: Transport
  let operationLauncher: OperationLauncher

  public var applicationID: ApplicationID {
    return transport.applicationID
  }

  public var apiKey: APIKey {
    return transport.apiKey
  }

  init(name: IndexName, transport: Transport, operationLauncher: OperationLauncher) {
    self.name = name
    self.transport = transport
    self.operationLauncher = operationLauncher
  }
  
  func wrapInWait<T: Task>(_ task: T) -> TaskWaitWrapper<T> {
    return .init(index: self, task: task)
  }

}

extension Index: Transport {

  func execute<Response: Codable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output, completion: @escaping (Result<Output, Error>) -> Void) -> Operation & TransportTask {
    return transport.execute(command, transform: transform, completion: completion)
  }

  func execute<Response: Codable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output) throws -> Output {
    return try transport.execute(command, transform: transform)
  }
  
  func execute<Output: Codable & Task>(_ command: AlgoliaCommand, completion: @escaping ResultTaskCallback<Output>) -> Operation & TransportTask {
    transport.execute(command, transform: wrapInWait, completion: completion)
  }
  
  func execute<Output: Codable & Task>(_ command: AlgoliaCommand) throws -> TaskWaitWrapper<Output> {
    try transport.execute(command, transform: wrapInWait)
  }

}

extension Index {
  
  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    return operationLauncher.launch(operation)
  }

  func launch<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    return try operationLauncher.launchSync(operation)
  }
  
}
