//
//  HTTPRequest.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

class HTTPRequest<Value: Codable>: AsyncOperation {
  
  let transport: Transport
  let method: HttpMethod
  let callType: CallType
  let path: String
  let body: Data?
  let requestOptions: RequestOptions?
  let completion: (ResultCallback<Value>)
  
  var result: Result<Value, Error>?
  
  init(transport: Transport,
       method: HttpMethod,
       callType: CallType,
       path: String,
       body: Data? = nil,
       requestOptions: RequestOptions?,
       completion: @escaping ResultCallback<Value>) {
    self.transport = transport
    self.method = method
    self.callType = callType
    self.path = path
    self.body = body
    self.requestOptions = requestOptions
    self.completion = completion
  }
  
  override func main() {
    transport.request(method: method, callType: callType, path: path, body: body, requestOptions: requestOptions) { [weak self] (result: Result<Value, Error>) in
      self?.result = result
      self?.state = .finished
      self?.completion(result)
    }
  }
  
}
