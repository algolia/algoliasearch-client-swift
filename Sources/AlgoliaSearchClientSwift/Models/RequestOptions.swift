//
//  RequestOptions.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

/**
 Every endpoint can configure a request locally by passing additional
 _headers_, _urlParameters_, _body_, _writeTimeout_, _readTimeout_.
*/
public struct RequestOptions {

  public var headers: [String: String] = [:]
  public var urlParameters: [String: String?] = [:]
  public var writeTimeout: TimeInterval?
  public var readTimeout: TimeInterval?
  public var body: [String: Any]?

  /**
   Add a header with key and value to headers.
  */
  public mutating func setHeader(_ value: String?, forKey key: HTTPHeaderKey) {
    headers[key.rawValue] = value
  }
  
  public func settingHeader(_ value: String?, forKey key: HTTPHeaderKey) -> Self {
    var mutableCopy = self
    mutableCopy.headers[key.rawValue] = value
    return mutableCopy
  }

  /**
   Add a url parameter with key and value to urlParameters.
  */
  public mutating func setParameter(_ value: String?, forKey key: HTTPParameterKey) {
    urlParameters[key.rawValue] = value
  }
  
  public func settingParameter(_ value: String?, forKey key: HTTPParameterKey) -> Self {
    var mutableCopy = self
    mutableCopy.urlParameters[key.rawValue] = value
    return mutableCopy
  }


  public func timeout(for callType: CallType) -> TimeInterval? {
    switch callType {
    case .read:
      return readTimeout
    case .write:
      return writeTimeout
    }
  }

}

public struct HTTPParameterKey: RawRepresentable, Hashable {

  public static let attributesToRetreive: HTTPParameterKey = "attributesToRetreive"
  public static let forwardToReplicas: HTTPParameterKey = "forwardToReplicas"
  public static let createIfNotExists: HTTPParameterKey = "createIfNotExists"
  public static let cursor: HTTPParameterKey = "cursor"
  public static let indexName: HTTPParameterKey = "indexName"
  public static let offset: HTTPParameterKey = "offset"
  public static let length: HTTPParameterKey = "length"
  public static let type: HTTPParameterKey = "type"


  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

}

extension HTTPParameterKey: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    rawValue = value
  }

}

public struct HTTPHeaderKey: RawRepresentable, Hashable {

  public static let algoliaUserID: HTTPHeaderKey = "X-Algolia-User-ID"
  public static let forwardedFor: HTTPHeaderKey = "X-Forwarded-For"
  public static let applicationID: HTTPHeaderKey = "X-Algolia-Application-Id"
  public static let apiKey: HTTPHeaderKey = "X-Algolia-API-Key"

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

}

extension HTTPHeaderKey: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    rawValue = value
  }

}

extension Optional where Wrapped == RequestOptions {
  
  func unwrapOrCreate() -> RequestOptions {
    return self ?? RequestOptions()
  }

  func updateOrCreate(_ parameters: @autoclosure () -> [HTTPParameterKey: String?]) -> RequestOptions? {
    let parameters = parameters()
    guard !parameters.isEmpty else {
      return self
    }
    var mutableRequestOptions = unwrapOrCreate()
    for (key, value) in parameters {
      mutableRequestOptions.setParameter(value, forKey: key)
    }

    return mutableRequestOptions
  }

}
