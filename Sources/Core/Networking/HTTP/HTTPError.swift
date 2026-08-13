//
//  HTTPError.swift
//
//
//  Created by Algolia on 02/03/2020.
//

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: - HTTPError

public struct HTTPError: Error, CustomStringConvertible {
    public let statusCode: HTTPStatusСode
    public let message: ErrorMessage?

    /// The Correlation-ID header of the failed response, when present.
    /// Quote it when contacting Algolia support.
    public let correlationID: String?

    public var description: String {
        let base = "Status code: \(self.statusCode) Message: \(self.message?.description ?? "No message")"
        guard let correlationID = self.correlationID else {
            return base
        }

        return "\(base) (Correlation-ID: \(correlationID))"
    }

    public init?(response: HTTPURLResponse?, data: Data?) {
        guard let response, !response.statusCode.belongs(to: .success) else {
            return nil
        }

        let message = data.flatMap { try? JSONDecoder().decode(ErrorMessage.self, from: $0) }
        self.init(
            statusCode: response.statusCode,
            message: message,
            correlationID: Self.correlationID(from: response)
        )
    }

    public init(statusCode: HTTPStatusСode, message: ErrorMessage?, correlationID: String? = nil) {
        self.statusCode = statusCode
        self.message = message
        self.correlationID = correlationID
    }

    /// Reads the Correlation-ID header case-insensitively: `allHeaderFields` keeps the
    /// server's casing, and its case-insensitive lookup is not guaranteed off Darwin.
    /// The unrelated X-Algolia-RequestID edge header must never be read instead.
    private static func correlationID(from response: HTTPURLResponse) -> String? {
        for (key, value) in response.allHeaderFields {
            if let name = key as? String,
               name.caseInsensitiveCompare("Correlation-ID") == .orderedSame {
                return value as? String
            }
        }

        return nil
    }
}
