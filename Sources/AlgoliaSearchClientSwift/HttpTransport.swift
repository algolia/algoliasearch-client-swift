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
 * Indicate whether the HTTP call performed is of type [read] (GET) or [write] (POST, PUT ..).
 * Used to determined which timeout duration to use.
 */
public enum CallType {
    case read, write
}

public enum HttpMethod: String {
  case GET, POST, PUT, DELETE
}

/**
 The transport layer is responsible of the serialization/deserialization and the retry strategy.
*/
class HttpTransport: Transport {
  
  let session: URLSession
  
  init() {
    session = .init(configuration: .default)
  }
  
  public func request(method: HttpMethod,
                      path: String,
                      callType: CallType,
                      body: Data,
                      requestOptions: RequestOptions) -> URLRequest {
    var urlComponents = URLComponents(string: path)!
    urlComponents.scheme = "https"
    urlComponents.queryItems = []
    var request = URLRequest(url: urlComponents.url!)
    request.httpMethod = method.rawValue
    request.httpBody = body
    request.timeoutInterval = requestOptions.timeout(for: callType) ?? 0
    return request
  }
  
}
