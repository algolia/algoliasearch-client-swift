//
//  ErrorMessage.swift
//
//
//  Created by Algolia on 22/12/2023.
//

import Foundation

public struct GenericError: Error, CustomStringConvertible {
    public init(description: String) {
        self.description = description
    }

    public var description: String
}

public struct ErrorMessage: Codable, CustomStringConvertible {
    public let description: String

    enum CodingKeys: String, CodingKey {
        case description = "message"
    }
}
