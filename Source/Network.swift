//
//  Copyright (c) 2015 Algolia
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

/// HTTP method definitions.
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

struct Manager {
    let session: NSURLSession
    
    init(HTTPHeaders: [String: String]) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = HTTPHeaders
        
        session = NSURLSession(configuration: configuration)
    }
    
    /// Creates a request for the specified URL.
    ///
    /// - parameter method: The HTTP method.
    /// - parameter URLString: The URL string.
    /// - parameter parameters: The parameters (will be encoding in JSON).
    /// - parameter block: A completion handler.
    ///
    /// - returns: The created request.
    func request(method: HTTPMethod, _ URLString: String, parameters: [String: AnyObject]? = nil, block: (NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) -> Request {
        let URLRequest = encodeParameter(CreateNSURLRequest(method, URL: URLString), parameters: parameters)
        
        let dataTask = session.dataTaskWithRequest(URLRequest, completionHandler: { (data, response, error) -> Void in
            let JSON = self.serializeResponse(data)
            dispatch_async(dispatch_get_main_queue()) {
                block(response as? NSHTTPURLResponse, JSON, error)
            }
        })

        let request = Request(session: session, task: dataTask)
        request.resume()
        
        return request
    }
    
    // MARK: - JSON
    
    private func encodeParameter(URLRequest: NSURLRequest, parameters: [String: AnyObject]?) -> NSURLRequest {
        guard let parameters = parameters else {
            return URLRequest
        }
        
        let data = try! NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions(rawValue: 0))
        
        let mutableURLRequest = URLRequest.mutableCopy() as! NSMutableURLRequest
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.HTTPBody = data
        
        return mutableURLRequest
    }
    
    private func serializeResponse(data: NSData?) -> (AnyObject?) {
        typealias Serializer = (NSData?) -> (AnyObject?)
        
        let JSONSerializer: Serializer = { (data) in
            guard let data = data where data.length > 0 else {
                return nil
            }
        
            return try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        }
        
        return JSONSerializer(data)
    }
}

struct Request {
    /// The session belonging to the underlying task.
    let session: NSURLSession
    
    /// The underlying task.
    let task: NSURLSessionTask
    
    /// The request sent to the server.
    var request: NSURLRequest {
        return task.originalRequest!
    }
    
    /// The response received from the server, if any.
    var response: NSHTTPURLResponse? {
        return task.response as? NSHTTPURLResponse
    }
    
    init(session: NSURLSession, task: NSURLSessionTask) {
        self.session = session
        self.task = task
    }
    
    /// Suspends the request.
    func suspend() {
        task.suspend()
    }
    
    /// Resumes the request.
    func resume() {
        task.resume()
    }
    
    /// Cancels the request.
    func cancel() {
        task.cancel()
    }
}

func CreateNSURLRequest(method: HTTPMethod, URL: String) -> NSURLRequest {
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URL)!)
    mutableURLRequest.HTTPMethod = method.rawValue
    
    return mutableURLRequest
}
