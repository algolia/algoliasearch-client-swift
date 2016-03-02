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

import UIKit

/// An `NSURLSessionTask` that is also an `NSOperation`, allowing it to be added to an `NSOperationQueue`.
public class URLSessionOperation: NSOperation {

    public let session: NSURLSession
    public let request: NSURLRequest
    public let completion: (NSData?, NSURLResponse?, NSError?) -> Void
    public var data: NSData?
    public var response: NSURLResponse?
    public var error: NSError?
    
    private var task : NSURLSessionTask?
    
    init(session: NSURLSession, request: NSURLRequest, completion: (NSData?, NSURLResponse?, NSError?) -> Void) {
        self.session = session
        self.request = request
        self.completion = completion
    }
    
    override public var asynchronous: Bool {
        get {
            return true
        }
    }
    
    // Overriding `NSOperation`'s properties.
    // I wish it could be simpler, but I couldn't find a more elegant way that stills allows firing KVO notifications.
    
    private var _executing : Bool = false {
        willSet {
            self.willChangeValueForKey("isExecuting")
        }
        didSet {
            self.didChangeValueForKey("isExecuting")
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
    
    private var _cancelled : Bool = false {
        willSet {
            self.willChangeValueForKey("isCancelled")
        }
        didSet {
            self.didChangeValueForKey("isCancelled")
        }
    }
    
    override public var executing: Bool {
        get {
            return _executing
        }
    }
    
    override public var finished: Bool {
        get {
            return _finished
        }
    }
    
    override public var cancelled: Bool {
        get {
            return _finished
        }
    }
    
    // Operations:
    
    override public func start() {
        task = session.dataTaskWithRequest(request) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            self.data = data
            self.response = response
            self.error = error
            self.completion(data, response, error)
            self._executing = false
            self._finished = true
        }

        task?.resume()
        self._executing = true
    }
    
    override public func cancel() {
        task?.cancel()
        self._cancelled = true
    }
}
