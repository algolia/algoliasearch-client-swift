//
//  DecodingErrorPrettyPrinter.swift
//
//
//  Created by Algolia on 18/12/2023.
//

import Foundation

struct DecodingErrorPrettyPrinter: CustomStringConvertible, CustomDebugStringConvertible {
    let decodingError: DecodingError

    init(decodingError: DecodingError) {
        self.decodingError = decodingError
    }

    private let prefix = "Decoding error"

    private func codingKeyDescription(_ key: CodingKey) -> String {
        if let index = key.intValue {
            return "[\(index)]"
        } else {
            return "'\(key.stringValue)'"
        }
    }

    private func codingPathDescription(_ path: [CodingKey]) -> String {
        path.map(codingKeyDescription).joined(separator: " -> ")
    }

    private func additionalComponents(for _: DecodingError) -> [String] {
        switch decodingError {
        case let .valueNotFound(_, context):
            return [codingPathDescription(context.codingPath), context.debugDescription]

        case let .keyNotFound(key, context):
            return [
                codingPathDescription(context.codingPath), "Key not found: \(codingKeyDescription(key))",
            ]

        case let .typeMismatch(type, context):
            return [codingPathDescription(context.codingPath), "Type mismatch. Expected: \(type)"]

        case let .dataCorrupted(context):
            return [codingPathDescription(context.codingPath), context.debugDescription]

        @unknown default:
            return [decodingError.localizedDescription]
        }
    }

    var description: String {
        ([prefix] + additionalComponents(for: decodingError)).joined(separator: ": ")
    }

    var debugDescription: String {
        description
    }
}

public extension DecodingError {
    var prettyDescription: String {
        DecodingErrorPrettyPrinter(decodingError: self).description
    }
}
