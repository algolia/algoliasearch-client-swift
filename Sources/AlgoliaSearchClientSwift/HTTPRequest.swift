//
//  HTTPRequest.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

class HTTPRequest<Value: Codable>: AsyncOperation, ResultContainer {
  
  let transport: Transport
  let command: AlgoliaCommand
  let completion: (ResultCallback<Value>)
  
  var result: Result<Value, Error>?
  
  init(transport: Transport,
       endpoint: AlgoliaCommand,
       completion: @escaping ResultCallback<Value>) {
    self.transport = transport
    self.command = endpoint
    self.completion = completion
  }
  
  override func main() {
    transport.request(request: command.urlRequest,
                      callType: command.callType,
                      requestOptions: command.requestOptions) { [weak self] (result: Result<Value, Error>) in
      self?.result = result
      self?.completion(result)
      self?.state = .finished
    }
  }
  
}
