//
//  UserAgent.swift
//
//
//  Created by Algolia on 14/04/2020.
//

import Foundation

// MARK: - UserAgent

public struct UserAgent: Hashable {
    // MARK: Lifecycle

    public init(title: String, version: String) {
        self.title = title
        self.version = version
    }

    // MARK: Public

    public let title: String
    public let version: String
}

// MARK: CustomStringConvertible

extension UserAgent: CustomStringConvertible {
    public var description: String {
        let versionOutput: String =
            if self.version.isEmpty {
                self.version
            } else {
                "(\(self.version))"
            }
        return [self.title, versionOutput].filter { !$0.isEmpty }.joined(separator: " ")
    }
}

// MARK: UserAgentExtending

extension UserAgent: UserAgentExtending {
    public var userAgentExtension: String {
        self.description
    }
}

extension UserAgent {
    static var library: UserAgent {
        UserAgent(title: "Algolia for Swift", version: Version.current.description)
    }
}

extension UserAgent {
    static var operatingSystem: UserAgent = {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        var osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion)"
        if osVersion.patchVersion != 0 {
            osVersionString += ".\(osVersion.patchVersion)"
        }
        if let osName {
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
        #elseif os(Linux)
            return "Linux"
        #else
            return nil
        #endif
    }
}
