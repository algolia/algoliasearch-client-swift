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


/// The error domain used for errors raised by this module.
public let AlgoliaSearchErrorDomain = "AlgoliaSearch"


/// HTTP status codes.
/// NOTE: Only those likely to be used by Algolia's servers and SDK are listed here.
///
public enum HTTPStatusCode: Int {
    case OK                                                     = 200
    case BadRequest                                             = 400
    case Unauthorized                                           = 401
    case Forbidden                                              = 403
    case MethodNotAllowed                                       = 405
    case InternalServerError                                    = 500
    case ServiceUnavailable                                     = 503
    
    public static func isSuccess(statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    public static func isClientError(statusCode: Int) -> Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    public static func isServerError(statusCode: Int) -> Bool {
        return statusCode >= 500 && statusCode < 600
    }
}

/// Determine if a given error is transient or not.
/// "Transient" means retrying an identical request at a later time might lead to a different result.
///
public func isErrorTransient(error: NSError) -> Bool {
    if (error.domain == AlgoliaSearchErrorDomain) {
        return HTTPStatusCode.isServerError(error.code)
    } else if (error.domain == NSURLErrorDomain) {
        return true
    } else {
        return false
    }
}
