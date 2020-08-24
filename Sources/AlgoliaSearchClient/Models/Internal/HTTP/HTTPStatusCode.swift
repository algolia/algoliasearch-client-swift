//
//  HTTPStatusCode.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

public typealias HTTPStatusСode = Int

extension HTTPStatusСode {

  static let notFound: HTTPStatusСode = 404
  static let requestTimeout: HTTPStatusСode = 408
  static let tooManyRequests: HTTPStatusСode = 429

  func belongs(to categories: HTTPStatusCategory...) -> Bool {
    return categories.map { $0.contains(self) }.contains(true)
  }

  var isError: Bool {
    return belongs(to: .clientError, .serverError)
  }

}

enum HTTPStatusCategory {

  case informational
  case success
  case redirection
  case clientError
  case serverError

  func contains(_ statusCode: HTTPStatusСode) -> Bool {
    return range.contains(statusCode)
  }

  var range: Range<Int> {
    switch self {
    case .informational:
      return 100..<200
    case .success:
      return 200..<300
    case .redirection:
      return 300..<400
    case .clientError:
      return 400..<500
    case .serverError:
      return 500..<600
    }
  }
}
