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
internal class Request: AsyncOperationWithCompletion {
    /// The client to which this request is related.
    let client: AbstractClient
    
    /// Request method.
    let method: HTTPMethod
    
    /// Hosts to which the request will be sent.
    let hosts: [String]
    
    /// Index of the first host that will be tried.
    let firstHostIndex: Int
    
    /// Index of the next host to be tried.
    var nextHostIndex: Int
    
    /// The URL path (part after the host and before the query string).
    let path: String
    
    /// URL parameters (query string part of the URL).
    let urlParameters: [String: String]?
    
    /// Optional HTTP headers.
    let headers: [String: String]?
    
    /// Optional body, in JSON format.
    let jsonBody: [String: Any]?
    
    /// Timeout for individual network queries.
    let timeout: TimeInterval
    
    /// Timeout to be used for the next query.
    var nextTimeout: TimeInterval
    
    /// The current network task.
    var task: URLSessionTask?
    
    // MARK: - Initialization
    
    init(client: AbstractClient, method: HTTPMethod, hosts: [String], firstHostIndex: Int, path: String, urlParameters: [String: String]?, headers: [String: String]?, jsonBody: [String: Any]?, timeout: TimeInterval, completion: CompletionHandler?) {
        self.client = client
        self.method = method
        self.hosts = client.upOrUnknownHosts(hosts)
        assert(!hosts.isEmpty)
        self.firstHostIndex = firstHostIndex
        self.nextHostIndex = firstHostIndex
        assert(firstHostIndex < hosts.count)
        self.path = path
        self.urlParameters = urlParameters
        // IMPORTANT: Enforce the `User-Agent` header on all requests.
        var patchedHeaders = headers ?? [:]
        patchedHeaders["User-Agent"] = AbstractClient.userAgentHeader
        self.headers = patchedHeaders
        self.jsonBody = jsonBody
        assert(jsonBody == nil || (method == .POST || method == .PUT))
        self.timeout = timeout
        self.nextTimeout = timeout
        super.init(completionHandler: completion)
        // Assign a descriptive name, but let the caller may change it afterwards (in contrast to getter override).
        if #available(iOS 8.0, *) {
            self.name = "Request{\(method) /\(path)}"
        }
    }
    
    // MARK: - Debug
    
    override var description: String {
        get {
            if #available(iOS 8.0, *) {
                return name ?? super.description
            } else {
                return super.description
            }
        }
    }
    
    // MARK: - Request logic
    
    /// Create a URL request for the specified host index.
    private func createRequest(_ hostIndex: Int) -> URLRequest {
        var urlString = "https://\(hosts[hostIndex])/\(path)"
        if let urlParameters = self.urlParameters {
            urlString += "?" + AbstractQuery.build(parameters: urlParameters)
        }
        let url = URL(string: urlString)! // the URL should always be well-formed, it's a programming error otherwise
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = nextTimeout
        if headers != nil {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if jsonBody != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let payload = try? JSONSerialization.data(withJSONObject: jsonBody!, options: JSONSerialization.WritingOptions(rawValue: 0)) {
                request.httpBody = payload
            } else {
                // The JSON we try to send should always be well-formed.
                assert(false, "Trying to send a request with invalid JSON")
            }
        }
        return request
    }
    
    private func startNext() {
        // Shortcut when cancelled.
        if _cancelled {
            return
        }
        
        // If there is no network reachability, don't even attempt to perform the request.
        #if !os(watchOS)
            if !client.shouldMakeNetworkCall() {
                self.callCompletion(content: nil, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil))
                return
            }
        #endif // !os(watchOS)
        
        let currentHostIndex = nextHostIndex
        let request = createRequest(currentHostIndex)
        nextHostIndex = (nextHostIndex + 1) % hosts.count
        task = client.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            var json: [String: Any]?
            var finalError: Error? = error
            // Shortcut in case of cancellation.
            if self.isCancelled {
                return
            }
            if (finalError == nil) {
                assert(data != nil)
                assert(response != nil)
                
                // Parse JSON response.
                // NOTE: We parse JSON even in case of failure to get the error message.
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                    if json == nil {
                        finalError = InvalidJSONError(description: "Server response not a JSON object")
                    }
                } catch let jsonError {
                    finalError = jsonError
                }
                
                // Handle HTTP status code.
                let httpResponse = response! as! HTTPURLResponse
                if (finalError == nil && !StatusCode.isSuccess(httpResponse.statusCode)) {
                    // Get the error message from JSON if available.
                    let errorMessage = json?["message"] as? String
                    finalError = HTTPError(statusCode: httpResponse.statusCode, message: errorMessage)
                }
            }
            assert(json != nil || finalError != nil)
            
            // Update host status.
            let down = finalError != nil && finalError!.isTransient()
            self.client.updateHostStatus(host: self.hosts[currentHostIndex], up: !down)
            
            // Success: call completion block.
            if finalError == nil {
                self.callCompletion(content: json, error: nil)
            }
            // Transient error and host array not exhausted: retry.
            else if finalError!.isTransient() && self.nextHostIndex != self.firstHostIndex {
                self.nextTimeout += self.timeout // raise the timeout
                self.startNext()
            }
            // Non-transient error, or no more hosts to retry: report the error.
            else {
                self.callCompletion(content: nil, error: finalError)
            }
        }
        task!.resume()
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Operation interface
    // ----------------------------------------------------------------------
    
    /// Start this request.
    override func start() {
        super.start()
        startNext()
    }
    
    /// Cancel this request.
    /// The completion block (if any was provided) will not be called after a request has been cancelled.
    ///
    /// WARNING: Cancelling a request may or may not cancel the underlying network call, depending how late the
    /// cancellation happens. In other words, a cancelled request may have already been executed by the server. In any
    /// case, cancelling never carries "undo" semantics.
    ///
    override func cancel() {
        task?.cancel()
        task = nil
        super.cancel()
    }
    
    override func finish() {
        task = nil
        super.finish()
    }
}
