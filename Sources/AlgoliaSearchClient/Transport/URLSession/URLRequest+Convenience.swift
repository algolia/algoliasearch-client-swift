//
//  URLRequest+Convenience.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

extension URLRequest: Builder {}

extension URLRequest {

  subscript(header key: HTTPHeaderKey) -> String? {

    get {
      return allHTTPHeaderFields?[key.rawValue]
    }

    set(newValue) {
      setValue(newValue, forHTTPHeaderField: key.rawValue)
    }

  }

  init<PC: PathComponent>(method: HTTPMethod, path: PC, body: Data? = nil, requestOptions: RequestOptions? = nil) {

    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.path = path.fullPath

    var request = URLRequest(url: urlComponents.url!)

    request.httpMethod = method.rawValue
    request.httpBody = body

    if let requestOptions = requestOptions {
      request.setRequestOptions(requestOptions)
    }

    self = request
  }

  mutating func setRequestOptions(_ requestOptions: RequestOptions) {

    // Append headers
    requestOptions.headers.forEach { setValue($0.value, forHTTPHeaderField: $0.key.rawValue) }

    // Append query items
    if let url = url, var currentComponents = URLComponents(string: url.absoluteString) {
      let requestOptionsItems = requestOptions.urlParameters.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }
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

extension URLRequest {

  var credentials: Credentials? {

    get {
      guard let appID = applicationID, let apiKey = apiKey else {
        return nil
      }
      return AlgoliaCredentials(applicationID: appID, apiKey: apiKey)
    }

    set {
      guard let newValue = newValue else {
        applicationID = nil
        apiKey = nil
        return
      }
      applicationID = newValue.applicationID
      apiKey = newValue.apiKey
    }

  }

  var applicationID: ApplicationID? {

    get {
      return self[header: .applicationID].flatMap(ApplicationID.init)
    }

    set {
      self[header: .applicationID] = newValue?.rawValue
    }
  }

  var apiKey: APIKey? {

    get {
      return self[header: .apiKey].flatMap(APIKey.init)
    }

    set {
      self[header: .apiKey] = newValue?.rawValue
    }

  }

}
