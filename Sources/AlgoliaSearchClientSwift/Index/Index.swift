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

  func performRequest<T: Codable>(for command: AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation {
    let request = HTTPRequest(transport: transport, command: command, completion: completion)
    queue.addOperation(request)
    return request
  }

  func performRequest<T: Codable & Task>(for command: AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation {
    let request = HTTPRequest(transport: transport, command: command, completion: completion)
    queue.addOperation(request)
    return request
  }

  func performSyncRequest<T: Codable>(for command: AlgoliaCommand) throws -> T {
    let request = HTTPRequest<T>(transport: transport, command: command, completion: { _ in })
    return try queue.performOperation(request)
  }

  enum Error: Swift.Error {
    case missingResult
  }

}

extension Index {

  @discardableResult func delete(requestOptions: RequestOptions? = nil,
                                 completion: @escaping ResultCallback<JSON>) -> Operation {
    let request = Command.Index.DeleteIndex(indexName: name,
                                            requestOptions: requestOptions)
    return performRequest(for: request, completion: completion)
  }
  
  @discardableResult func delete(requestOptions: RequestOptions? = nil) throws -> JSON {
    let request = Command.Index.DeleteIndex(indexName: name,
                                            requestOptions: requestOptions)
    return try performSyncRequest(for: request)
  }

}
