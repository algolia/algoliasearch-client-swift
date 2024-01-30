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
  public init(data: Data?, response: URLResponse?, error: Swift.Error?) {
    if let error {
      self = .failure(TransportError.requestError(error))
      return
    }

    if let httpError = HTTPError(response: response as? HTTPURLResponse, data: data) {
      self = .failure(TransportError.httpError(httpError))
      return
    }

    guard let data else {
      self = .failure(TransportError.missingData)
      return
    }

    do {
      let jsonDecoder = JSONDecoder()
      jsonDecoder.dateDecodingStrategy = .custom(ClientDateCodingStrategy.decoding)
      let object = try jsonDecoder.decode(Success.self, from: data)
      self = .success(object)
    } catch {
      self = .failure(TransportError.decodingFailure(error))
    }
  }
}
