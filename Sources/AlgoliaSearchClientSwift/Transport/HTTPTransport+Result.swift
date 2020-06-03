//
//  HTTPTransport+Result.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

extension URLSessionTask: Cancellable {}

extension URLSession: HTTPRequester {

  public func perform<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> TransportTask {
    let task = dataTask(with: request) { (data, response, error) in
      let result = Result<T, Error>(data: data, response: response, error: error)
      if case .success = result,
        let data = data,
        let responseJSON = try? JSONDecoder().decode(JSON.self, from: data) {
        Logger.loggingService.log(level: .debug, message: "Response: \(responseJSON)")
      }
      completion(result)
    }
    task.resume()
    return task
  }

}

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
      self = .failure(HttpTransport.Error.missingData)
      return
    }

    do {
      let jsonDecoder = JSONDecoder()
      jsonDecoder.dateDecodingStrategy = .custom(ClientDateCodingStrategy.decoding)
      let object = try jsonDecoder.decode(Success.self, from: data)
      self = .success(object)
    } catch let error {
      self = .failure(error)
    }

  }

}
