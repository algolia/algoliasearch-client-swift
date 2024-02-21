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
    case wait(String)

    public var errorDescription: String? {
        switch self {
        case let .requestError(error):
            "Request failed: \(error.localizedDescription)"
        case let .httpError(error):
            "HTTP error: \(error)"
        case let .noReachableHosts(errors):
            "All hosts are unreachable. Intermediate errors: \(errors.map(\.localizedDescription).joined(separator: ", "))"
        case .missingData:
            "Missing response data"
        case .decodingFailure:
            "Response decoding failed"
        case let .runtimeError(error):
            "\(error)"
        case let .invalidCredentials(credential):
            "`\(credential)` is missing."
        case let .invalidArgument(argument, operationId):
            "Parameter `\(argument)` is required when calling `\(operationId)`."
        case let .wait(error):
            "\(error)"
        }
    }
}
