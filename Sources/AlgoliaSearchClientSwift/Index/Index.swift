//
//  Index.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct Index {

  public let name: IndexName
  let transport: Transport
  let queue: OperationQueue

  init(name: IndexName, transport: Transport, queue: OperationQueue) {
    self.name = name
    self.transport = transport
    self.queue = queue
  }

  func launch<T: Codable>(_ command: AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation & TransportTask {
    let request = HTTPRequest(transport: transport, command: command, completion: completion)
    queue.addOperation(request)
    return request
  }

  func launch<T: Codable>(_ command: AlgoliaCommand) throws -> T {
    let request = HTTPRequest<T>(transport: transport, command: command, completion: { _ in })
    return try queue.performOperation(request)
  }

  enum Error: Swift.Error {
    case missingResult
  }

}

