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

  static let urlAllowed: CharacterSet = .alphanumerics.union(.init(charactersIn: "-._~")) // as per RFC 3986

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

  init(command: AlgoliaCommand) {

    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.path = command.path.absoluteString.removingPercentEncoding!

    if let urlParameters = command.requestOptions?.urlParameters {
      urlComponents.queryItems = urlParameters.map { (key, value) in .init(name: key.rawValue, value: value) }
    }

    var request = URLRequest(url: urlComponents.url!)

    request.httpMethod = command.method.rawValue
    request.httpBody = command.body

    if let requestOptions = command.requestOptions {

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

    request.httpBody = command.body
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
      do {
        try setAPIKey(newValue)
      } catch let error {
        Logger.error("Couldn't set API key in the request body due to error: \(error)")
      }
    }

  }

  static let maxHeaderAPIKeyLength = 500

  private mutating func setAPIKey(_ apiKey: APIKey?) throws {

    guard let apiKeyValue = apiKey?.rawValue, apiKeyValue.count > URLRequest.maxHeaderAPIKeyLength else {
      self[header: .apiKey] = apiKey?.rawValue
      return
    }

    Logger.warning("The API length is > \(URLRequest.maxHeaderAPIKeyLength). Attempt to insert it into request body.")

    guard let body = httpBody else {
      throw APIKeyError.missingHTTPBody
    }

    let decodingResult = Result { try JSONDecoder().decode(JSON.self, from: body) }
    guard case .success(let bodyJSON) = decodingResult else {
      if case .failure(let error) = decodingResult {
        throw APIKeyError.bodyDecodingJSONError(error)
      }
      return
    }

    guard case .dictionary(var jsonDictionary) = bodyJSON else {
      throw APIKeyError.bodyNonKeyValueJSON
    }

    jsonDictionary["apiKey"] = .string(apiKeyValue)

    let encodingResult = Result { try JSONEncoder().encode(jsonDictionary) }
    guard case .success(let updatedBody) = encodingResult else {
      if case .failure(let error) = encodingResult {
        throw APIKeyError.bodyEncodingJSONError(error)
      }
      return
    }

    httpBody = updatedBody
  }

  enum APIKeyError: Error, CustomStringConvertible {
    case missingHTTPBody
    case bodyDecodingJSONError(Error)
    case bodyNonKeyValueJSON
    case bodyEncodingJSONError(Error)

    var description: String {
      switch self {
      case .missingHTTPBody:
        return "Request doesn't contain HTTP body"
      case .bodyDecodingJSONError(let error):
        return "HTTP body JSON decoding error: \(error)"
      case .bodyEncodingJSONError(let error):
        return "HTTP body JSON encoding error: \(error)"
      case .bodyNonKeyValueJSON:
        return "HTTP body JSON is not key-value type"
      }
    }
  }

}
