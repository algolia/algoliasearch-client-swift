//
//  HttpTransport+Error.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

public enum TransportError: Error, LocalizedError {

    case requestError(Error)
    case httpError(HTTPError)
    case noReachableHosts(intermediateErrors: [Error])
    case missingData
    case decodingFailure(Error)

    public var errorDescription: String? {
      switch self {
      case .requestError(let error):
        return "Request failed: \(error)"
      case .httpError(let error):
        return "HTTP error: \(error)"
      case .noReachableHosts(let errors):
        return "All hosts are unreachable. Intermediate errors: \(errors)"
      case .missingData:
        return "Missing response data"
      case .decodingFailure:
        return "Response decoding failed"
      }
    }
}
