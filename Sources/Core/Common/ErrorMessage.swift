//
//  ErrorMessage.swift
//
//
//  Created by Algolia on 22/12/2023.
//

import Foundation

// MARK: - GenericError

public struct GenericError: Error, CustomStringConvertible {
    // MARK: Lifecycle

    public init(description: String) {
        self.description = description
    }

    // MARK: Public

    public var description: String
}

// MARK: - ErrorMessage

public struct ErrorMessage: Codable, CustomStringConvertible {
    // MARK: Public

    public let description: String

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case description = "message"
    }
}
