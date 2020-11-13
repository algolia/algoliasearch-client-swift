//
//  URLRequest+Convenience.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest: Builder {}

extension CharacterSet {
  
  static var uriAllowed = CharacterSet.urlQueryAllowed.subtracting(.init(charactersIn: "+"))
  
}

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
  
    if let urlParameters = requestOptions?.urlParameters {
      urlComponents.queryItems = urlParameters.map { (key, value) in .init(name: key.rawValue, value: value) }
    }

    var request = URLRequest(url: urlComponents.url!)

    request.httpMethod = method.rawValue
    request.httpBody = body
    
    if let requestOptions = requestOptions {
      
      requestOptions.headers.forEach { header in
        let (value, field) = (header.value, header.key.rawValue)
        request.setValue(value, forHTTPHeaderField: field)
      }
      
      // If body is set in query parameters, it will override the body passed as parameter to this function
      if let body = requestOptions.body, !body.isEmpty {
        let jsonEncodedBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonEncodedBody
      }
      
    }
        
    request.httpBody = body
    self = request
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
