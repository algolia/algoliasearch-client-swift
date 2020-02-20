//
//  HTTPStatusCode.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

enum HTTPStatusCode: Int {
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
  
  var isInformational: Bool {
    return (100..<200).contains(rawValue)
  }
  
  var isSuccess: Bool {
    return (200..<300).contains(rawValue)
  }
  
  var isRedirection: Bool {
    return (300..<400).contains(rawValue)
  }
    
  var isClientError: Bool {
    return (400..<500).contains(rawValue)
  }
  
  var isServerError: Bool {
    return (500..<600).contains(rawValue)
  }
  
  var isError: Bool {
    return isClientError || isServerError
  }
  
}
