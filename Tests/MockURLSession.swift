//
//  MockURLSession.swift
//  AlgoliaSearch
//
//  Created by Clément Le Provost on 25/03/16.
//  Copyright © 2016 Algolia. All rights reserved.
//

import Foundation

@testable import AlgoliaSearch


/// A mock response for a mock URL session.
///
public struct MockResponse {
    // In case of success
    // ------------------
    
    /// HTTP status code to return.
    public let statusCode: Int?
    
    /// HTTP headers to return.
    public let headers: [String : String]?
    
    public let data: NSData?
    
    // In case of (network) error
    // --------------------------
    
    /// Error to return.
    public let error: NSError?
    
    /// Construct a successful response with a JSON body.
    public init(statusCode: Int, jsonBody: AnyObject) {
        self.statusCode = statusCode
        self.headers = nil
        self.data = try? NSJSONSerialization.dataWithJSONObject(jsonBody, options: []) ?? NSData()
        self.error = nil
    }
    
    /// Construct a successful response with a raw data body.
    public init(statusCode: Int, data: NSData) {
        self.statusCode = statusCode
        self.headers = nil
        self.data = data
        self.error = nil
    }
    
    /// Construct an error response.
    public init(error: NSError) {
        self.statusCode = nil
        self.headers = nil
        self.data = nil
        self.error = error
    }
}

/// A replacement for `NSURLSession` used for mocking network requests.
///
public class MockURLSession: URLSession {
    /// Predefined set of responses for the specified URLs.
    public var responses: [String: MockResponse] = [String: MockResponse]()
    
    /// Whether network requests can be cancelled.
    public var cancellable: Bool = true
    
    let defaultResponse = MockResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: nil))
    
    public func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        let details = responses[request.URL!.absoluteString] ?? defaultResponse
        let task = MockURLSessionDataTask(request: request, details: details, completionHandler: completionHandler)
        task.cancellable = self.cancellable
        return task
    }
}

/// A mock replacement for `NSURLSessionDataTask`.
public class MockURLSessionDataTask: NSURLSessionDataTask {
    typealias CompletionHandler = (NSData?, NSURLResponse?, NSError?) -> Void

    /// Response to answer
    let details: MockResponse
    
    /// Whether `cancel()` actually does something on this request.
    var cancellable: Bool = true
    
    /// Whether this request was cancelled.
    var cancelled: Bool = false
    
    let request: NSURLRequest
    let completionHandler: CompletionHandler
    
    init(request: NSURLRequest, details: MockResponse, completionHandler: CompletionHandler) {
        self.request = request
        self.details = details
        self.completionHandler = completionHandler
    }
    
    override public func resume() {
        dispatch_async(dispatch_get_main_queue()) {
            // Do not call any delegate method if cancelled.
            if self.cancelled {
                return
            }
            // In case of error: just return the error.
            else if self.details.error != nil {
                self.completionHandler(nil, nil, self.details.error)
            }
            // In case of success: return a response and a data.
            else {
                assert(self.details.statusCode != nil)
                let httpResponse = NSHTTPURLResponse(URL: self.request.URL!, statusCode: self.details.statusCode!, HTTPVersion: "HTTP/1.1", headerFields: self.details.headers)!
                assert(self.details.data != nil)
                self.completionHandler(self.details.data, httpResponse, nil)
            }
        }
    }
    
    override public func cancel() {
        if cancellable {
            cancelled = true
        }
    }
}
