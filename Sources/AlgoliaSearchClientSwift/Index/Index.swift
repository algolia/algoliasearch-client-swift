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
  let configuration: Configuration

  public var applicationID: ApplicationID {
    return transport.applicationID
  }

  public var apiKey: APIKey {
    return transport.apiKey
  }

  init(name: IndexName, transport: Transport, operationLauncher: OperationLauncher, configuration: Configuration) {
    self.name = name
    self.transport = transport
    self.operationLauncher = operationLauncher
    self.configuration = configuration
  }

}

extension Index: TransportContainer {}

extension Index {

  func execute<Output: Codable & Task>(_ command: AlgoliaCommand, completion: @escaping ResultTaskCallback<Output>) -> Operation & TransportTask {
    transport.execute(command, transform: WaitableWrapper.wrap(with: self), completion: completion)
  }

  func execute<Output: Codable & Task>(_ command: AlgoliaCommand) throws -> WaitableWrapper<Output> {
    try transport.execute(command, transform: WaitableWrapper.wrap(with: self))
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
