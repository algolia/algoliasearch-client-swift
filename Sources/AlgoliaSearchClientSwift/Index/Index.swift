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
  
  func performRequest<T: Codable>(for endpoint: AlgoliaRequest, completion: @escaping ResultCallback<T>) {
    let request = HTTPRequest(transport: transport, endpoint: endpoint, completion: completion)
    queue.addOperation(request)
  }
  
}


extension Index {
  
  func delete(requestOptions: RequestOptions? = nil,
              completion: @escaping ResultCallback<JSON>) {
    let request = Request.Index.DeleteIndex(indexName: name,
                                            requestOptions: requestOptions)
    performRequest(for: request, completion: completion)
  }
  
}

extension Request {
  enum Index {}
}

extension Request.Index {
  
  struct DeleteIndex: AlgoliaRequest {
    
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
