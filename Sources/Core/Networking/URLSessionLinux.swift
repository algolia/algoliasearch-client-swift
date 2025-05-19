//
//  URLSessionLinux.swift
//
//
//  Created by Algolia on 16/01/2024.
//

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public extension URLSession {
    /// A reimplementation of `URLSession.shared.data(from: url)` required for Linux
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Returns: Data and response.
    ///
    /// - Usage:
    ///
    ///     let (data, response) = try await URLSession.shared.asyncData(for: urlRequest)
    func asyncData(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var dataTask: URLSessionDataTask?
        let cancellingHandler = {
            dataTask?.cancel()
        }

        return try await withTaskCancellationHandler {
            try BridgedTask.checkCancellation()

            return try await withCheckedThrowingContinuation { continuation in
                guard !BridgedTask.isCancelled else {
                    continuation.resume(throwing: CancellationError())
                    return
                }

                dataTask = self.dataTask(with: urlRequest) { data, response, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let response = response as? HTTPURLResponse else {
                        continuation.resume(
                            throwing: AlgoliaError.decodingFailure(
                                GenericError(description: "Unable to decode HTTPURLResponse")
                            )
                        )
                        return
                    }
                    guard let data else {
                        continuation.resume(throwing: AlgoliaError.missingData)
                        return
                    }
                    continuation.resume(returning: (data, response))
                }

                dataTask?.resume()
            }

        } onCancel: {
            cancellingHandler()
        }
    }
}
