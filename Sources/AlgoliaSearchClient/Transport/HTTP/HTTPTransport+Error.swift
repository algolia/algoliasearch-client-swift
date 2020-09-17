//
//  HttpTransport+Error.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

extension HTTPTransport {

  enum Error: Swift.Error, LocalizedError {
    case noReachableHosts
    case missingData
    case decodingFailure(Swift.Error)
    
    var localizedDescription: String {
      switch self {
      case .noReachableHosts:
        return "All hosts are unreachable"
      case .missingData:
        return "Missing response data"
      case .decodingFailure:
        return "Response decoding failed"
      }
    }
  }

}
