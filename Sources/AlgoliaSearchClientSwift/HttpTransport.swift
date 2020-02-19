//
//  HttpTransport.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

protocol Transport {
  
  
}

/**
 The transport layer is responsible of the serialization/deserialization and the retry strategy.
*/
class HttpTransport: Transport {
  
  let session: URLSession
  
  init() {
    session = .init(configuration: .default)
  }
  
  public func request(method: String, body: Data) -> URLRequest {
    var urlComponents = URLComponents(string: "www.algolia.com")!
    urlComponents.scheme = "https"
    urlComponents.queryItems = []
    var request = URLRequest(url: urlComponents.url!)
    request.httpMethod = method
    request.httpBody = body
    return request
  }
  
}
