//
//  HttpTransport+Error.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

extension HTTPTransport {

  enum Error: Swift.Error {
    case noReachableHosts
    case missingData
  }

}
