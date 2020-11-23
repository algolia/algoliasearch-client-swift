//
//  HTTPTransport+Result.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Result where Success: Decodable, Failure == Error {

  init(data: Data?, response: URLResponse?, error: Swift.Error?) {

    if let error = error {
      self = .failure(error)
      return
    }

    if let httpError = HTTPError(response: response as? HTTPURLResponse, data: data) {
      self = .failure(httpError)
      return
    }

    guard let data = data else {
      self = .failure(HTTPTransport.Error.missingData)
      return
    }

    do {
      let jsonDecoder = JSONDecoder()
      jsonDecoder.dateDecodingStrategy = .custom(ClientDateCodingStrategy.decoding)
      let object = try jsonDecoder.decode(Success.self, from: data)
      self = .success(object)
    } catch let error {
      self = .failure(HTTPTransport.Error.decodingFailure(error))
    }

  }

}
