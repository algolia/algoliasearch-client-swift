//
//  Command+Custom.swift
//  
//
//  Created by Vladislav Fitc on 11/02/2021.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {
  
  struct Custom: AlgoliaCommand {
    
    let method: HTTPMethod
    let callType: CallType
    let path: Path
    let body: Data?
    let requestOptions: RequestOptions?
    
    init(method: HTTPMethod,
         callType: CallType,
         path: Path,
         body: Data?,
         requestOptions: RequestOptions?) {
      self.method = method
      self.callType = callType
      self.path = path
      self.body = body
      self.requestOptions = requestOptions
    }

    
    init(callType: CallType,
         urlRequest: URLRequest,
         requestOptions: RequestOptions?) throws {
      self.callType = callType
      guard let method = urlRequest.httpMethod.flatMap(HTTPMethod.init(rawValue:)) else {
        throw AlgoliaCommandError.invalidHTTPMethod
      }
      self.method = method
      guard let path = (urlRequest.url?.path).flatMap(Path.init) else {
        throw AlgoliaCommandError.invalidPath
      }
      self.path = path
      self.body = urlRequest.httpBody
      self.requestOptions = requestOptions
    }
    
    enum AlgoliaCommandError: Error {
      case invalidHTTPMethod
      case invalidPath
    }
  }
  
}
