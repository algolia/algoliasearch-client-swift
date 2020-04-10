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
  
}

extension Index {
  
  func perform<T: Codable>(_ command: AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation & TransportTask {
    return transport.execute(command, completion: completion)
  }
  
  func perform<T: Codable>(_ command: AlgoliaCommand) throws -> T {
    return try transport.execute(command)
  }
  
  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    return operationLauncher.launch(operation)
  }
  
  func launch<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    return try operationLauncher.launchSync(operation)
  }
  
}
