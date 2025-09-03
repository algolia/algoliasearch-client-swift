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
    case noReachableHosts(intermediateErrors: [Error], exposeIntermediateErrors: Bool)
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
        case let .noReachableHosts(errors, exposeIntermediateErrors):
            "All hosts are unreachable. If the error persists, please visit our help center https://alg.li/support-unreachable-hosts or reach out to the Algolia Support team: https://alg.li/support " +
                (
                    exposeIntermediateErrors ?
                        "Intermediate errors:\n- \(errors.map(\.localizedDescription).joined(separator: "\n- "))" :
                        "You can use 'exposeIntermediateErrors: true' in the config to investigate."
                )
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
