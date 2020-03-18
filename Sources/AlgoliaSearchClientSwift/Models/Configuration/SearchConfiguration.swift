//
//  SearchConfigration.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

public struct SearchConfigration: Configuration, Credentials {
  
  public let applicationID: ApplicationID
  
  public let apiKey: APIKey
  
  public var writeTimeout: TimeInterval
  
  public var readTimeout: TimeInterval
  
  public var logLevel: LogLevel
  
  public var hosts: [RetryableHost]
  
  public var defaultHeaders: [HTTPHeaderKey : String]?
  
  init(applicationID: ApplicationID,
       apiKey: APIKey,
       writeTimeout: TimeInterval = DefaultConfiguration.default.writeTimeout,
       readTimeout: TimeInterval = DefaultConfiguration.default.readTimeout,
       logLevel: LogLevel = DefaultConfiguration.default.logLevel,
       defaultHeaders: [HTTPHeaderKey: String]? = DefaultConfiguration.default.defaultHeaders) {
    self.applicationID = applicationID
    self.apiKey = apiKey
    self.writeTimeout = writeTimeout
    self.readTimeout = readTimeout
    self.logLevel = logLevel
    self.hosts = applicationID.searchHosts
    self.defaultHeaders = defaultHeaders
  }
  
}


extension ApplicationID {
  
  var searchHosts: [RetryableHost] {
    let hostSuffixes: [(suffix: String, callType: CallType?)] = [
      ("-dsn.algolia.net", .read),
      (".algolia.net", .write),
      ("-1.algolianet.com", nil),
      ("-2.algolianet.com", nil),
      ("-3.algolianet.com", nil),
    ]
    return hostSuffixes.map {
      let url = URL(string: "\(rawValue)\($0.suffix)")!
      return RetryableHost(url: url, callType: $0.callType)
    }
  }
  
}
