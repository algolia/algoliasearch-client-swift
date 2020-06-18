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

  public static var attributesToRetreive: HTTPParameterKey { #function }
  public static var forwardToReplicas: HTTPParameterKey { #function }
  public static var clearExistingRules: HTTPParameterKey { #function }
  public static var clearExistingSynonyms: HTTPParameterKey { #function }
  public static var createIfNotExists: HTTPParameterKey { #function }
  public static var cursor: HTTPParameterKey { #function }
  public static var indexName: HTTPParameterKey { #function }
  public static var offset: HTTPParameterKey { #function }
  public static var limit: HTTPParameterKey { #function }
  public static var length: HTTPParameterKey { #function }
  public static var type: HTTPParameterKey { #function }
  public static var language: HTTPParameterKey { #function }
  public static var aroundLatLng: HTTPParameterKey { #function }
  public static var page: HTTPParameterKey { #function }
  public static var hitsPerPage: HTTPParameterKey { #function }
  public static var getClusters: HTTPParameterKey { #function }
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
  public static let userAgent: HTTPHeaderKey = "User-Agent"

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
