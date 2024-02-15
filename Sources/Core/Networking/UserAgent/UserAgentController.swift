//
//  UserAgentController.swift
//
//
//  Created by Algolia on 15/06/2020.
//

import Foundation

// MARK: - UserAgentController

public enum UserAgentController {
    public internal(set) static var extensions: [UserAgentExtending] = [
        UserAgent.library, UserAgent.operatingSystem,
    ]

    public static var userAgents: [UserAgent] {
        extensions.compactMap { $0 as? UserAgent }
    }

    public static var httpHeaderValue: String {
        extensions.map(\.userAgentExtension).joined(separator: "; ")
    }

    /// Append user agent to include into each API call.
    public static func append(_ userAgentExtension: UserAgentExtending) {
        if self.userAgents.contains(
            where: { $0.userAgentExtension == userAgentExtension.userAgentExtension }
        ) {
            Logger.loggingService.log(level: LogLevel.info, message: "User-Agent already appended")
            return
        }

        self.extensions.append(userAgentExtension)
    }
}

// MARK: - UserAgentExtending

public protocol UserAgentExtending {
    var userAgentExtension: String { get }
}
