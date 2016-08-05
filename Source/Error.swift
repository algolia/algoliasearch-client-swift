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


/// Status codes.
///
/// + Note: Only those likely to be used by Algolia's servers and SDK are listed here.
///
public enum StatusCode: Int {
    // MARK: Regular HTTP status codes
    
    /// Success.
    case OK                                                     = 200
    
    /// Invalid parameters.
    case BadRequest                                             = 400
    
    /// Invalid authentication.
    case Unauthorized                                           = 401
    
    /// Operation unauthorized with the provided credentials.
    case Forbidden                                              = 403
    
    /// The HTTP method used in the request is not supported for the targeted endpoint.
    ///
    /// + Note: Should never occur when using this library.
    ///
    case MethodNotAllowed                                       = 405
    
    /// The server has encountered a fatal internal error.
    case InternalServerError                                    = 500
    
    /// The server is temporarily down.
    case ServiceUnavailable                                     = 503
    
    // MARK: Custom status codes
    
    /// Unknown error.
    case Unknown                                                = -1
    
    /// The server replied ill-formed JSON (syntax error).
    case IllFormedResponse                                      = 600
    
    /// The server replied an invalid response (grammar error).
    case InvalidResponse                                        = 601
    
    /// Test whether a status code represents success.
    public static func isSuccess(statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    /// Test whether a status code represents a client error.
    public static func isClientError(statusCode: Int) -> Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    /// Test whether a status code represents a server error.
    public static func isServerError(statusCode: Int) -> Bool {
        return statusCode >= 500 && statusCode < 600
    }
}

extension NSError {
    /// Determine if this error is transient or not.
    /// "Transient" means retrying an identical request at a later time might lead to a different result.
    ///
    func isTransient() -> Bool {
        if (domain == Client.ErrorDomain) {
            return StatusCode.isServerError(code)
        } else if (domain == NSURLErrorDomain) {
            return true
        } else {
            return false
        }
    }
}

