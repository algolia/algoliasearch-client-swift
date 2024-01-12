//
//  RequestOptions.swift
//
//
//  Created by Algolia on 11/01/2024.
//

import Foundation

public class RequestOptions {
  private(set) var headers: [String: String]
  private(set) var queryItems: [URLQueryItem]
  private(set) var readTimeout: TimeInterval?
  private(set) var writeTimeout: TimeInterval?
  private(set) var body: [String: Any?]

  public init(
    headers: [String: String] = [:],
    queryItems: [URLQueryItem] = [],
    readTimeout: TimeInterval? = nil,
    writeTimeout: TimeInterval? = nil,
    body: [String: Any?] = [:]
  ) {
    self.headers = headers
    self.queryItems = queryItems
    self.readTimeout = readTimeout
    self.writeTimeout = writeTimeout
    self.body = body
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
