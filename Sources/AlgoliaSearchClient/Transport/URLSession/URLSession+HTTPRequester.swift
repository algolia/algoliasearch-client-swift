//
//  URLSession+HTTPRequester.swift
//  
//
//  Created by Vladislav Fitc on 15/06/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
