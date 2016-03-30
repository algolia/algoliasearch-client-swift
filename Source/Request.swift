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


/// An API request.
///
/// This class encapsulates a sequence of normally one (nominal case), potentially many (in case of retry) network
/// calls into a high-level operation. This operation can be cancelled by the user.
///
@objc public class Request: NSOperation {
    let session: URLSession
    
    /// Request method.
    let method: HTTPMethod
    
    /// Hosts to which the request will be sent.
    let hosts: [String]
    
    /// Index of the first host that will be tried.
    let firstHostIndex: Int
    
    /// Index of the next host to be tried.
    var nextHostIndex: Int
    
    /// The URL path (actually everything after the host, so including the query string).
    let path: String
    
    /// Optional HTTP headers.
    let headers: [String: String]?
    
    /// Optional body, in JSON format.
    let jsonBody: [String: AnyObject]?
    
    /// Timeout for individual network queries.
    let timeout: NSTimeInterval
    
    /// Timeout to be used for the next query.
    var nextTimeout: NSTimeInterval
    
    /// The current network task.
    var task: NSURLSessionTask?
    
    /// User completion block to be called.
    let completion: CompletionHandler?
    
    init(session: URLSession, method: HTTPMethod, hosts: [String], firstHostIndex: Int, path: String, headers: [String: String]?, jsonBody: [String: AnyObject]?, timeout: NSTimeInterval, completion: CompletionHandler?) {
        self.session = session
        self.method = method
        self.hosts = hosts
        assert(!hosts.isEmpty)
        self.firstHostIndex = firstHostIndex
        self.nextHostIndex = firstHostIndex
        assert(firstHostIndex < hosts.count)
        self.path = path
        self.headers = headers
        self.jsonBody = jsonBody
        assert(jsonBody == nil || (method == .POST || method == .PUT))
        self.timeout = timeout
        self.nextTimeout = timeout
        self.completion = completion
    }
    
    /// Create a URL request for the specified host index.
    private func createRequest(hostIndex: Int) -> NSMutableURLRequest {
        let url = NSURL(string: "https://\(hosts[hostIndex])/\(path)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = method.rawValue
        request.timeoutInterval = nextTimeout
        if headers != nil {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if jsonBody != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let payload = try? NSJSONSerialization.dataWithJSONObject(jsonBody!, options: NSJSONWritingOptions(rawValue: 0)) {
                request.HTTPBody = payload
            } else {
                // The JSON we try to send should always be well-formed.
                assert(false, "Trying to send a request with invalid JSON")
            }
        }
        return request
    }
    
    private func startNext() {
        assert(_executing)
        let request = createRequest(nextHostIndex)
        nextHostIndex = (nextHostIndex + 1) % hosts.count
        task = session.dataTaskWithRequest(request) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            var json: [String: AnyObject]?
            var finalError: NSError? = error
            // Shortcut in case of cancellation.
            if self.cancelled {
                return
            }
            if (finalError == nil) {
                assert(data != nil)
                assert(response != nil)
                
                // Parse JSON response.
                // NOTE: We parse JSON even in case of failure to get the error message.
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject]
                    if json == nil {
                        finalError = NSError(domain: AlgoliaSearchErrorDomain, code: StatusCode.InvalidResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "Server response not a JSON object"])
                    }
                } catch let jsonError as NSError {
                    finalError = NSError(domain: AlgoliaSearchErrorDomain, code: StatusCode.IllFormedResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "Server returned ill-formed JSON", NSUnderlyingErrorKey: jsonError])
                } catch {
                    finalError = NSError(domain: AlgoliaSearchErrorDomain, code: StatusCode.Unknown.rawValue, userInfo: [NSLocalizedDescriptionKey: "Unknown error when parsing JSON"])
                }
                
                // Handle HTTP status code.
                let httpResponse = response! as! NSHTTPURLResponse
                if (finalError == nil && !StatusCode.isSuccess(httpResponse.statusCode)) {
                    var userInfo = [String: AnyObject]()
                    
                    // Get the error message from JSON if available.
                    if let errorMessage = json?["message"] as? String {
                        userInfo[NSLocalizedDescriptionKey] = errorMessage
                    }
                    
                    finalError = NSError(domain: AlgoliaSearchErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
                }
            }
            assert(json != nil || finalError != nil)
            
            // Success: call completion block.
            if finalError == nil {
                self.callCompletion(json, error: nil)
            }
            // Transient error and host array not exhausted: retry.
            else if isErrorTransient(finalError!) && self.nextHostIndex != self.firstHostIndex {
                self.nextTimeout += self.timeout // raise the timeout
                self.startNext()
            }
            // Non-transient error, or no more hosts to retry: report the error.
            else {
                self.callCompletion(nil, error: finalError)
            }
        }
        task?.resume()
    }
    
    /// Finish this operation.
    /// This method should be called exactly once per operation.
    private func callCompletion(content: [String: AnyObject]?, error: NSError?) {
        assert(!_finished)
        if completion != nil && !_cancelled {
            completion!(content: content, error: error)
        }
        _executing = false
        _finished = true
    }
    
    // ----------------------------------------------------------------------
    // MARK: - NSOperation interface
    // ----------------------------------------------------------------------
    
    // MARK: Properties
    
    // Mark this operation as aynchronous.
    @objc override public var asynchronous: Bool {
        get {
            return true
        }
    }
    
    // NOTE: Overriding `NSOperation`'s properties
    // -------------------------------------------
    // These properties are defined as read-only by `NSOperation`. As a consequence, they must be computed properties.
    // But they must also fire KVO notifications, which are crucial for `NSOperationQueue` to work.
    // This is why we use a private (underscore-prefixed) property to store the state.
    
    private var _executing : Bool = false {
        willSet {
            self.willChangeValueForKey("isExecuting")
        }
        didSet {
            self.didChangeValueForKey("isExecuting")
        }
    }
    
    @objc override public var executing: Bool {
        get {
            return _executing
        }
    }
    
    private var _finished : Bool = false {
        willSet {
            self.willChangeValueForKey("isFinished")
        }
        didSet {
            self.didChangeValueForKey("isFinished")
        }
    }
    
    @objc override public var finished: Bool {
        get {
            return _finished
        }
    }
    
    private var _cancelled : Bool = false {
        willSet {
            self.willChangeValueForKey("isCancelled")
        }
        didSet {
            self.didChangeValueForKey("isCancelled")
        }
    }
    
    @objc override public var cancelled: Bool {
        get {
            return _cancelled
        }
    }
    
    // MARK: Operations
    
    /// Start this request.
    @objc override public func start() {
        assert(!_executing)
        self._executing = true
        startNext()
    }
    
    /// Cancel this request.
    /// The completion block (if any was provided) will not be called after a request has been cancelled.
    ///
    /// WARNING: Cancelling a request may or may not cancel the underlying network call, depending how late the
    /// cancellation happens. In other words, a cancelled request may have already been executed by the server. In any
    /// case, cancelling never carries "undo" semantics.
    ///
    @objc public override func cancel() {
        self._cancelled = true
        task?.cancel()
    }
}
