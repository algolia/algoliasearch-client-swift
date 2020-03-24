//
//  HTTPTransport+Result.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

extension URLSession: HTTPRequester {

  func perform<T: Codable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
    let task = dataTask(with: request) { (data, response, error) in
      let result = Result<T, Error>(data: data, response: response, error: error)
      completion(result)
    }
    task.resume()
  }

}

extension Result where Success: Codable, Failure == Error {

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
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      jsonDecoder.dateDecodingStrategy = .formatted(formatter)
      let object = try jsonDecoder.decode(Success.self, from: data)
      self = .success(object)
    } catch let error {
      self = .failure(error)
    }

  }

}
