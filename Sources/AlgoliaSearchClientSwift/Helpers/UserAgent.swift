//
//  UserAgent.swift
//  
//
//  Created by Vladislav Fitc on 14/04/2020.
//

import Foundation

public struct UserAgent: Hashable {

  public let title: String
  public let version: String

  public init(title: String, version: String) {
    self.title = title
    self.version = version
  }

}

extension UserAgent: CustomStringConvertible {

  public var description: String {
    return [title, version].filter { !$0.isEmpty }.joined(separator: " ")
  }

}

extension UserAgent {

  static var library: UserAgent {
    return UserAgent(title: "Algolia for Swift", version: Version.current.description)
  }

}

extension UserAgent {

  static var operatingSystem: UserAgent = {
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    var osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion)"
    if osVersion.patchVersion != 0 {
      osVersionString += ".\(osVersion.patchVersion)"
    }
    if let osName = osName {
      return UserAgent(title: osName, version: osVersionString)
    } else {
      return UserAgent(title: ProcessInfo.processInfo.operatingSystemVersionString, version: "")
    }
  }()

  private static var osName: String? {
    #if os(iOS)
      return "iOS"
    #elseif os(OSX)
      return "macOS"
    #elseif os(tvOS)
      return "tvOS"
    #elseif os(watchOS)
      return "watchOS"
    #else
      return nil
    #endif
  }

}
