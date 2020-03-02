//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

extension Result where Success: Codable, Failure == Error {
  
  init(data: Data?, response: URLResponse?, error: Swift.Error?) {
    
    if let error = error {
      self = .failure(error)
    }
    
    if let httpError = HTTPError(response: response as? HTTPURLResponse, data: data) {
      self = .failure(httpError)
    }
    
    guard let data = data else {
      self = .failure(HttpTransport.Error.missingData)
      return
    }
        
    do {
      let object = try JSONDecoder().decode(Success.self, from: data)
      self = .success(object)
    } catch let error {
      self = .failure(error)
    }
    
  }
  
}
