//
//  SearchConfiguration.swift
//
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

public struct SearchConfiguration: Configuration, Credentials, Builder {
  public let applicationID: ApplicationID

  public let apiKey: APIKey

  public var writeTimeout: TimeInterval

  public var readTimeout: TimeInterval

  public var logLevel: LogLevel

  public var hosts: [RetryableHost]

  public var defaultHeaders: [HTTPHeaderKey: String]?

  public var batchSize: Int

  public init(
    applicationID: ApplicationID,
    apiKey: APIKey
  ) {
    self.applicationID = applicationID
    self.apiKey = apiKey
    writeTimeout = DefaultConfiguration.default.writeTimeout
    readTimeout = DefaultConfiguration.default.readTimeout
    logLevel = DefaultConfiguration.default.logLevel
    hosts = Hosts.forApplicationID(applicationID)
    defaultHeaders = DefaultConfiguration.default.defaultHeaders
    batchSize = DefaultConfiguration.default.batchSize
  }
}
