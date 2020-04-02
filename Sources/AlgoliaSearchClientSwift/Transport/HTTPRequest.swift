//
//  HTTPRequest.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

class HTTPRequest<Value: Codable>: AsyncOperation, ResultContainer, TransportTask {
  
  let transport: Transport
  let command: AlgoliaCommand
  let completion: (ResultCallback<Value>)
  var underlyingTask: (TransportTask)?
  var result: Result<Value, Error>?
  
  var progress: Progress {
    return underlyingTask?.progress ?? Progress()
  }

  init(transport: Transport,
       command: AlgoliaCommand,
       completion: @escaping ResultCallback<Value>) {
    self.transport = transport
    self.command = command
    self.underlyingTask = nil
    self.completion = completion
  }

  override func main() {
    underlyingTask = transport.request(request: command.urlRequest,
                                     callType: command.callType,
                                     requestOptions: command.requestOptions) { [weak self] (result: Result<Value, Error>) in
      self?.result = result
      self?.completion(result)
      self?.state = .finished
    }
  }
  
  override func cancel() {
    super.cancel()
    underlyingTask?.cancel()
  }

}
