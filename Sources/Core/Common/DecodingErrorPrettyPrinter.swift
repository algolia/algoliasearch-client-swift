//
//  DecodingErrorPrettyPrinter.swift
//
//
//  Created by Algolia on 18/12/2023.
//

import Foundation

// MARK: - DecodingErrorPrettyPrinter

struct DecodingErrorPrettyPrinter: CustomStringConvertible, CustomDebugStringConvertible {
    // MARK: Lifecycle

    init(decodingError: DecodingError) {
        self.decodingError = decodingError
    }

    // MARK: Internal

    let decodingError: DecodingError

    var description: String {
        ([self.prefix] + self.additionalComponents(for: self.decodingError)).joined(separator: ": ")
    }

    var debugDescription: String {
        self.description
    }

    // MARK: Private

    private let prefix = "Decoding error"

    private func codingKeyDescription(_ key: CodingKey) -> String {
        if let index = key.intValue {
            "[\(index)]"
        } else {
            "'\(key.stringValue)'"
        }
    }

    private func codingPathDescription(_ path: [CodingKey]) -> String {
        path.map(self.codingKeyDescription).joined(separator: " -> ")
    }

    private func additionalComponents(for _: DecodingError) -> [String] {
        switch self.decodingError {
        case let .valueNotFound(_, context):
            return [self.codingPathDescription(context.codingPath), context.debugDescription]

        case let .keyNotFound(key, context):
            return [
                self.codingPathDescription(context.codingPath), "Key not found: \(self.codingKeyDescription(key))",
            ]

        case let .typeMismatch(type, context):
            return [self.codingPathDescription(context.codingPath), "Type mismatch. Expected: \(type)"]

        case let .dataCorrupted(context):
            return [self.codingPathDescription(context.codingPath), context.debugDescription]

        @unknown default:
            return [self.decodingError.localizedDescription]
        }
    }
}

public extension DecodingError {
    var prettyDescription: String {
        DecodingErrorPrettyPrinter(decodingError: self).description
    }
}
