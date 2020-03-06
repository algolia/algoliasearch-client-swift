//
//  HTTPRequest.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

class HTTPRequest<Value: Codable>: AsyncOperation {
  
  let transport: Transport
  let endpoint: AlgoliaRequest
  let completion: (ResultCallback<Value>)
  
  var result: Result<Value, Error>?
  
  init(transport: Transport,
       endpoint: AlgoliaRequest,
       completion: @escaping ResultCallback<Value>) {
    self.transport = transport
    self.endpoint = endpoint
    self.completion = completion
  }
  
  override func main() {
    transport.request(request: endpoint.urlRequest,
                      callType: endpoint.callType,
                      requestOptions: endpoint.requestOptions) { [weak self] (result: Result<Value, Error>) in
      self?.result = result
      self?.completion(result)
      self?.state = .finished
    }
  }
  
}
