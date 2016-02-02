//
//  URLSessionOperation.swift
//  Pods
//
//  Created by Clément Le Provost on 02/02/16.
//
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
