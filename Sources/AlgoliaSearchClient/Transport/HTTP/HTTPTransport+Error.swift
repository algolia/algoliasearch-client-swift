//
//  HttpTransport+Error.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

extension HTTPTransport {

  enum Error: Swift.Error, LocalizedError {
    case noReachableHosts(intermediateErrors: [Swift.Error])
    case missingData
    case decodingFailure(Swift.Error)

    var errorDescription: String? {
      switch self {
      case .noReachableHosts(let errors):
        return "All hosts are unreachable. Intermediate errors: \(errors)"
      case .missingData:
        return "Missing response data"
      case .decodingFailure:
        return "Response decoding failed"
      }
    }
  }

}
