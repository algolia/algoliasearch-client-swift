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

  public init(applicationID: ApplicationID,
              apiKey: APIKey) {
    self.applicationID = applicationID
    self.apiKey = apiKey
    self.writeTimeout = DefaultConfiguration.default.writeTimeout
    self.readTimeout = DefaultConfiguration.default.readTimeout
    self.logLevel = DefaultConfiguration.default.logLevel
    self.hosts = Hosts.forApplicationID(applicationID)
    self.defaultHeaders = DefaultConfiguration.default.defaultHeaders
    self.batchSize = DefaultConfiguration.default.batchSize
  }

}
