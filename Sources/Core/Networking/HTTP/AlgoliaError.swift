//
//  AlgoliaError.swift
//
//
//  Created by Algolia on 02/03/2020.
//

import Foundation

public enum AlgoliaError: Error, LocalizedError {
    case requestError(Error)
    case httpError(HTTPError)
    case noReachableHosts(intermediateErrors: [Error])
    case missingData
    case decodingFailure(Error)
    case runtimeError(String)
    case invalidCredentials(String)
    case invalidArgument(String, String)

    public var errorDescription: String? {
        switch self {
        case let .requestError(error):
            return "Request failed: \(error.localizedDescription)"
        case let .httpError(error):
            return "HTTP error: \(error)"
        case let .noReachableHosts(errors):
            return
                "All hosts are unreachable. Intermediate errors: \(errors.map(\.localizedDescription).joined(separator: ", "))"
        case .missingData:
            return "Missing response data"
        case .decodingFailure:
            return "Response decoding failed"
        case let .runtimeError(error):
            return "\(error)"
        case let .invalidCredentials(credential):
            return "`\(credential)` is missing."
        case let .invalidArgument(argument, operationId):
            return "Parameter `\(argument)` is required when calling `\(operationId)`."
        }
    }
}
