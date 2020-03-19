//
//  URLRequest+Convenience.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

extension URLRequest {
  
  init(method: HttpMethod,
       path: String,
       body: Data? = nil,
       requestOptions: RequestOptions? = nil) {
    
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.path = path
    
    var request = URLRequest(url: urlComponents.url!)
        
    request.httpMethod = method.rawValue
    request.httpBody = body
    
    if let requestOptions = requestOptions {
      request.setRequestOptions(requestOptions)
    }
    
    self = request
  }
  
  mutating func setValue(_ value: String?, for key: HTTPHeaderKey) {
    setValue(value, forHTTPHeaderField: key.rawValue)
  }
  
  mutating func set(_ credentials: Credentials) {
    setApplicationID(credentials.applicationID)
    setAPIKey(credentials.apiKey)
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
  
  func withHost(_ host: RetryableHost, requestOptions: RequestOptions?) -> URLRequest {
    var output = self
    
    // Update timeout interval
    output.timeoutInterval = host.timeout(requestOptions: requestOptions)
    
    // Update url
    var urlComponents = URLComponents(url: url!, resolvingAgainstBaseURL: false)
    urlComponents?.host = host.url.absoluteString
    output.url = urlComponents?.url

    return output
  }
  
}
