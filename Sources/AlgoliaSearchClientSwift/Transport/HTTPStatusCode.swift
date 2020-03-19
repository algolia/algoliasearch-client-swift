//
//  HTTPStatusCode.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

public enum HTTPStatusCode: Int {
    // 100 Informational
    case `continue` = 100
    case switchingProtocols
    case processing
    // 200 Success
    case ok = 200
    case created
    case accepted
    case nonAuthoritativeInformation
    case noContent
    case resetContent
    case partialContent
    case multiStatus
    case alreadyReported
    case iMUsed = 226
    // 300 Redirection
    case multipleChoices = 300
    case movedPermanently
    case found
    case seeOther
    case notModified
    case useProxy
    case switchProxy
    case temporaryRedirect
    case permanentRedirect
    // 400 Client Error
    case badRequest = 400
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case payloadTooLarge
    case uriTooLong
    case unsupportedMediaType
    case rangeNotSatisfiable
    case expectationFailed
    case imATeapot
    case misdirectedRequest = 421
    case unprocessableEntity
    case locked
    case failedDependency
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests
    case requestHeaderFieldsTooLarge = 431
    case unavailableForLegalReasons = 451
    // 500 Server Error
    case internalServerError = 500
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case loopDetected
    case notExtended = 510
    case networkAuthenticationRequired
}

extension HTTPStatusCode {
  
  enum Category {
    
    case informational
    case success
    case redirection
    case clientError
    case serverError
    
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
  
  func belongs(to categories: Category...) -> Bool {
    return categories.map { $0.range.contains(rawValue) }.contains(true)
  }
  
  var isError: Bool {
    return belongs(to: .clientError, .serverError)
  }
  
}
