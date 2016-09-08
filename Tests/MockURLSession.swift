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
    
    public let data: Data?
    
    // In case of (network) error
    // --------------------------
    
    /// Error to return.
    public let error: Error?
    
    /// Construct a successful response with a JSON body.
    public init(statusCode: Int, jsonBody: Any) {
        self.statusCode = statusCode
        self.headers = nil
        self.data = (try? JSONSerialization.data(withJSONObject: jsonBody, options: [])) ?? Data()
        self.error = nil
    }
    
    /// Construct a successful response with a raw data body.
    public init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.headers = nil
        self.data = data
        self.error = nil
    }
    
    /// Construct an error response.
    public init(error: Error) {
        self.statusCode = nil
        self.headers = nil
        self.data = nil
        self.error = error
    }
}

/// A replacement for `NSURLSession` used for mocking network requests.
///
public class MockURLSession: AlgoliaSearch.URLSession {
    /// Predefined set of responses for the specified URLs.
    public var responses: [String: MockResponse] = [String: MockResponse]()
    
    /// Whether network requests can be cancelled.
    public var cancellable: Bool = true
    
    let defaultResponse = MockResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: nil))
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let details = responses[request.url!.absoluteString] ?? defaultResponse
        let task = MockURLSessionDataTask(request: request, details: details, completionHandler: completionHandler)
        task.cancellable = self.cancellable
        return task
    }
}

/// A mock replacement for `NSURLSessionDataTask`.
public class MockURLSessionDataTask: URLSessionDataTask {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    /// Response to answer
    let details: MockResponse
    
    /// Whether `cancel()` actually does something on this request.
    var cancellable: Bool = true
    
    /// Whether this request was cancelled.
    var cancelled: Bool = false
    
    let request: URLRequest
    let completionHandler: CompletionHandler
    
    init(request: URLRequest, details: MockResponse, completionHandler: @escaping CompletionHandler) {
        self.request = request
        self.details = details
        self.completionHandler = completionHandler
    }
    
    override public func resume() {
        DispatchQueue.main.async {
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
                let httpResponse = HTTPURLResponse(url: self.request.url!, statusCode: self.details.statusCode!, httpVersion: "HTTP/1.1", headerFields: self.details.headers)!
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
