//
//  PersonalizationConfiguration.swift
//  
//
//  Created by Vladislav Fitc on 05/07/2021.
//

import Foundation

public struct PersonalizationConfiguration: Configuration, Credentials {

  public let applicationID: ApplicationID

  public let apiKey: APIKey

  public var writeTimeout: TimeInterval

  public var readTimeout: TimeInterval

  public var logLevel: LogLevel

  public var hosts: [RetryableHost]

  public var defaultHeaders: [HTTPHeaderKey: String]?

  public var batchSize: Int

  init(applicationID: ApplicationID,
       apiKey: APIKey,
       region: Region? = nil,
       writeTimeout: TimeInterval = DefaultConfiguration.default.writeTimeout,
       readTimeout: TimeInterval = DefaultConfiguration.default.readTimeout,
       logLevel: LogLevel = DefaultConfiguration.default.logLevel,
       defaultHeaders: [HTTPHeaderKey: String]? = DefaultConfiguration.default.defaultHeaders,
       batchSize: Int = DefaultConfiguration.default.batchSize) {
    self.applicationID = applicationID
    self.apiKey = apiKey
    self.writeTimeout = writeTimeout
    self.readTimeout = readTimeout
    self.logLevel = logLevel
    self.hosts = Hosts.recommendation(forRegion: region)
    self.defaultHeaders = defaultHeaders
    self.batchSize = batchSize
  }

}

@available(*, deprecated, renamed: "PersonalizationConfiguration")
public typealias RecommendationConfiguration = PersonalizationConfiguration
