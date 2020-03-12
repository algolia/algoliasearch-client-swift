//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct Index {
  
  public let name: IndexName
  let transport: Transport
  let queue: OperationQueue
  
  init(name: IndexName) {
    let transport = HttpTransport(configuration: DefaultConfiguration.default)
    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    self.init(name: name, transport: transport, queue: queue)
  }
  
  init(name: IndexName, transport: Transport, queue: OperationQueue) {
    self.name = name
    self.transport = transport
    self.queue = queue
  }
  
  func performRequest<T: Codable>(for endpoint: AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation {
    let request = HTTPRequest(transport: transport, endpoint: endpoint, completion: completion)
    queue.addOperation(request)
    return request
  }
  
  func performRequest<T: Codable & Task>(for endpoint: AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation {
    let request = HTTPRequest(transport: transport, endpoint: endpoint, completion: completion)
    queue.addOperation(request)
    return request
  }
  
  func performSyncRequest<T: Codable>(for endpoint: AlgoliaCommand) throws -> T {
    let request = HTTPRequest<T>(transport: transport, endpoint: endpoint, completion: { _ in })
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
  
}

extension Command {
  enum Index {}
}

extension Command.Index {
  
  struct DeleteIndex: AlgoliaCommand {
    
    let callType: CallType = .write
    let urlRequest: URLRequest
    let requestOptions: RequestOptions?
    
    init(indexName: IndexName,
         requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      let path = indexName.toPath()
      urlRequest = .init(method: .delete,
                         path: path,
                         requestOptions: requestOptions)
    }
    
  }
  
}
