//
//  Error.swift
//  Pods
//
//  Created by Clément Le Provost on 04/02/16.
//
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
