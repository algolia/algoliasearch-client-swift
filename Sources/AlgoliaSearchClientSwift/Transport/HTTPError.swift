//
//  HTTPError.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

public struct HTTPError: Error {

  public let statusCode: HTTPStatusСode
  public let message: ErrorMessage?

  public init?(response: HTTPURLResponse?, data: Data?) {
    guard let response = response, !response.statusCode.belongs(to: .success) else {
      return nil
    }

    let message = data.flatMap { try? JSONDecoder().decode(ErrorMessage.self, from: $0) }
    self.init(statusCode: response.statusCode, message: message)
  }

  public init(statusCode: HTTPStatusСode, message: ErrorMessage?) {
    self.statusCode = statusCode
    self.message = message
  }

}

public struct ErrorMessage: Codable, CustomStringConvertible {

  enum CodingKeys: String, CodingKey {
    case description = "message"
  }

  public let description: String

}
