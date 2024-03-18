//
//  Iterable.swift
//
//
//  Created by Algolia on 19/02/2024.
//

import Foundation

public struct IterableError<T> {
    let validate: (T) -> Bool
    let message: ((T) -> String)?

    public init(validate: @escaping (T) -> Bool, message: ((T) -> String)? = nil) {
        self.validate = validate
        self.message = message
    }
}

public func createIterable<T>(
    execute: (T?) async throws -> T,
    validate: (T) -> Bool,
    aggregator: ((T) -> Void)? = nil,
    timeout: () -> TimeInterval = {
        0
    },
    error: IterableError<T>? = nil
) async throws -> T {
    func executor(previousResponse: T? = nil) async throws -> T {
        let response = try await execute(previousResponse)

        if let aggregator {
            aggregator(response)
        }

        if validate(response) {
            return response
        }

        if let error, error.validate(response) {
            guard let errorMessage = error.message else {
                throw AlgoliaError.wait("An error occured")
            }

            throw AlgoliaError.wait(errorMessage(response))
        }

        try await BridgedTask.sleep(nanoseconds: UInt64(timeout()) * 1_000_000_000)

        return try await executor(previousResponse: response)
    }

    return try await executor()
}
