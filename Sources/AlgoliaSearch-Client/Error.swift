//
//  Copyright (c) 2015-2016 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// The returned JSON is syntactically correct, but grammatically invalid.
/// For example, it a mandatory attribute is missing, or an attribute is not of the expected type.
///
public struct InvalidJSONError: CustomNSError {
  /// Further description of this error.
  public let description: String

  public init(description: String) {
    self.description = description
  }

  // MARK: CustomNSError protocol

  // ... for Objective-C bridging.

  public static var errorDomain: String = String(reflecting: InvalidJSONError.self)

  public var errorCode: Int { return 601 }

  public var errorUserInfo: [String: Any] {
    return [
      NSLocalizedDescriptionKey: description,
    ]
  }
}

/// A non-OK HTTP status code.
///
public struct HTTPError: CustomNSError {
  /// The HTTP status code returned by the server.
  public let statusCode: Int

  /// Optional message returned by the server.
  public let message: String?

  public init(statusCode: Int, message: String? = nil) {
    self.statusCode = statusCode
    self.message = message
  }

  // MARK: CustomNSError protocol

  // ... for Objective-C bridging.

  public static var errorDomain: String = String(reflecting: HTTPError.self)

  public var errorCode: Int { return statusCode }

  public var errorUserInfo: [String: Any] {
    var userInfo = [String: Any]()
    if let message = message {
      userInfo[NSLocalizedDescriptionKey] = message
    }
    return userInfo
  }
}

/// HTTP status codes.
///
/// + Note: Only those likely to be used by Algolia's servers and SDK are listed here.
///
public enum StatusCode: Int {
  // MARK: Status codes

  /// Success.
  case ok = 200

  /// Invalid parameters.
  case badRequest = 400

  /// Invalid authentication.
  case unauthorized = 401

  /// Operation unauthorized with the provided credentials.
  case forbidden = 403

  /// The targeted resource does not exist.
  case notFound = 404

  /// The HTTP method used in the request is not supported for the targeted endpoint.
  ///
  /// + Note: Should never occur when using this library.
  ///
  case methodNotAllowed = 405

  /// The server has encountered a fatal internal error.
  case internalServerError = 500

  /// The server is temporarily down.
  case serviceUnavailable = 503

  // MARK: Status ranges

  /// Test whether a status code represents success.
  public static func isSuccess(_ statusCode: Int) -> Bool {
    return statusCode >= 200 && statusCode < 300
  }

  /// Test whether a status code represents a client error.
  public static func isClientError(_ statusCode: Int) -> Bool {
    return statusCode >= 400 && statusCode < 500
  }

  /// Test whether a status code represents a server error.
  public static func isServerError(_ statusCode: Int) -> Bool {
    return statusCode >= 500 && statusCode < 600
  }
}

extension NSError {
  /// Determine if this error is transient or not.
  /// "Transient" means retrying an identical request at a later time might lead to a different result.
  ///
  func isTransient() -> Bool {
    if domain == HTTPError.errorDomain {
      return StatusCode.isServerError(code)
    } else if domain == NSURLErrorDomain {
      return true
    } else {
      return false
    }
  }
}

extension Error {
  // WARNING: Calling `isTransient()` on an `Error` instance will fail to compile because this method is not part
  // of the `Error` protocol, so we need to define it here as well... **but** when tentatively casting `Error` to
  // `NSError` will always succeed! (We get a warning if we try to write a tentative cast.)

  /// Determine if this error is transient or not.
  /// "Transient" means retrying an identical request at a later time might lead to a different result.
  ///
  func isTransient() -> Bool {
    let error = self as NSError
    return error.isTransient()
  }
}
