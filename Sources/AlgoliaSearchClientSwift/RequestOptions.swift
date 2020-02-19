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
  
  public var headers: [String: String?]
  public var urlParameters: [String: String?]
  public var writeTimeout: TimeInterval? = nil
  public var readTimeout: TimeInterval? = nil
  public var body: [String: Any]? = nil
    
  /**
   Add a header with key and value to headers.
  */
  public mutating func setHeader(_ value: String?, forKey key: HeaderKey) {
    headers[key.rawValue] = value
  }
  
  /**
   Add a url parameter with key and value to urlParameters.
  */
  public mutating func setParameter(_ value: String?, forKey key: String) {
    urlParameters[key] = value
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

public extension RequestOptions {
  
  struct HeaderKey: RawRepresentable {
    
    public static let algoliaUserID = "X-Algolia-User-ID"
    public static let forwardedFor = "X-Forwarded-For"
    
    public var rawValue: String
    
    public init(rawValue: String) {
      self.rawValue = rawValue
    }
        
  }
  
}

extension RequestOptions.HeaderKey: ExpressibleByStringLiteral {
  
  public init(stringLiteral value: String) {
    rawValue = value
  }
  
}
