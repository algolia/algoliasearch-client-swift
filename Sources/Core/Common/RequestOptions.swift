//
//  RequestOptions.swift
//
//
//  Created by Algolia on 11/01/2024.
//

import Foundation

public class RequestOptions {
  private(set) var headers: [String: String]?
  private(set) var queryItems: [URLQueryItem]?
  private(set) var readTimeout: TimeInterval?
  private(set) var writeTimeout: TimeInterval?
  private(set) var body: [String: Any?]?

  public init(
    headers: [String: String]? = nil,
    queryItems: [URLQueryItem]? = nil,
    readTimeout: TimeInterval? = nil,
    writeTimeout: TimeInterval? = nil,
    body: [String: Any?]? = nil
  ) {
    self.headers = headers
    self.queryItems = queryItems
    self.readTimeout = readTimeout
    self.writeTimeout = writeTimeout
    self.body = body
  }

  public static func + (lhs: RequestOptions, rhs: RequestOptions?) -> RequestOptions {
    guard let rhs = rhs else {
      return lhs
    }

    var finalHeaders: [String: String]? = lhs.headers
    var finalQueryItems: [URLQueryItem]? = lhs.queryItems
    var finalBody: [String: Any?]? = lhs.body
    var finalReadTimeout: TimeInterval? = lhs.readTimeout
    var finalWriteTimeout: TimeInterval? = lhs.writeTimeout

    if let rhsHeaders = rhs.headers {
      finalHeaders = (finalHeaders ?? [:]).merging(rhsHeaders) { (_, new) in new }
    }

    if let rhsQueryItems = rhs.queryItems {
      finalQueryItems = lhs.queryItems ?? []
      rhsQueryItems.forEach { queryItem in finalQueryItems?.append(queryItem) }
    }

    if let rhsBody = rhs.body {
      finalBody = rhsBody
    }

    if let rhsReadTimeout = rhs.readTimeout {
      finalReadTimeout = rhsReadTimeout
    }

    if let rhsWriteTimeout = rhs.writeTimeout {
      finalWriteTimeout = rhsWriteTimeout
    }

    return RequestOptions(
      headers: finalHeaders,
      queryItems: finalQueryItems,
      readTimeout: finalReadTimeout,
      writeTimeout: finalWriteTimeout,
      body: finalBody
    )
  }

  public func timeout(for callType: CallType) -> TimeInterval? {
    switch callType {
    case .read:
      return readTimeout
    case .write:
      return writeTimeout
    }
  }

  public func addHeaders(_ aHeaders: [String: String]) {
    self.headers?.merge(aHeaders) { (_, new) in new }
  }

  public func addHeader(name: String, value: String) -> Self {
    if !value.isEmpty {
      self.headers?[name] = value
    }
    return self
  }
}
