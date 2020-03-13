//
//  HTTPTransport+Result.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

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
