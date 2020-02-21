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
  var configuration: Configuration
  var retryStrategy: RetryStrategy
  let credentials: Credentials?
  
  init(configuration: Configuration,
       credentials: Credentials? = nil,
       retryStrategy: RetryStrategy? = nil) {
    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders
    session = .init(configuration: .default)
    self.configuration = configuration
    self.credentials = credentials
    self.retryStrategy = retryStrategy ?? RetryStrategy(configuration: configuration)
  }
  
  public func request(method: HttpMethod,
                      path: String,
                      callType: CallType,
                      body: Data?,
                      requestOptions: RequestOptions?) {
    let hosts = retryStrategy.callableHosts(for: callType)
    let host = hosts.first!
    let req = request(host: host, method: method, path: path, callType: callType, body: body, requestOptions: requestOptions)
    session.dataTask(with: req) { (data, response, error) in
      switch retryStrategy.decide(host: host, response: response!, error: error)
    }
  }
  
  public func request(host: RetryableHost,
                      method: HttpMethod,
                      path: String,
                      callType: CallType,
                      body: Data?,
                      requestOptions: RequestOptions?) -> URLRequest {
        
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = host.url.absoluteString
    urlComponents.path = path
    var request = URLRequest(url: urlComponents.url!)
    
    if let credentials = credentials {
      request.setApplicationID(credentials.applicationID)
      request.setAPIKey(credentials.apiKey)
    }
    request.httpMethod = method.rawValue
    request.timeoutInterval = requestOptions?.timeout(for: callType) ?? configuration.timeout(for: callType)
    request.httpBody = body
    if let requestOptions = requestOptions {
      request.setRequestOptions(requestOptions)
    }
    return request
  }
  
}

extension URLRequest {
  
  mutating func setValue(_ value: String?, for key: HTTPHeaderKey) {
    setValue(value, forHTTPHeaderField: key.rawValue)
  }
  
  mutating func setApplicationID(_ applicationID: ApplicationID) {
    setValue(applicationID.rawValue, for: .applicationID)
  }
  
  mutating func setAPIKey(_ apiKey: APIKey) {
    setValue(apiKey.rawValue, for: .apiKey)
  }
  
  mutating func setRequestOptions(_ requestOptions: RequestOptions) {

    // Append headers
    requestOptions.headers.forEach { setValue($0.value, forHTTPHeaderField: $0.key) }
    
    // Append query items
    if let url = url, var currentComponents = URLComponents(string: url.absoluteString) {
      let requestOptionsItems = requestOptions.urlParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
      var existingItems = currentComponents.queryItems ?? []
      existingItems.append(contentsOf: requestOptionsItems)
      currentComponents.queryItems = existingItems
      self.url = currentComponents.url
    }
    
    // Set body
    if
      let body = requestOptions.body,
      let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) {
      httpBody = jsonData
    }
  }
  
}
