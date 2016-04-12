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

/// An asynchronous operation.
///
/// This class provides its subclasses the way to manually control `NSOperation`'s standard properties:
///
/// - `executing`
/// - `finished`
/// - `cancel`
///
class AsyncOperation: NSOperation {
    
    // Mark this operation as aynchronous.
    override var asynchronous: Bool {
        get {
            return true
        }
    }
    
    // NOTE: Overriding `NSOperation`'s properties
    // -------------------------------------------
    // These properties are defined as read-only by `NSOperation`. As a consequence, they must be computed properties.
    // But they must also fire KVO notifications, which are crucial for `NSOperationQueue` to work.
    // This is why we use a private (underscore-prefixed) property to store the state.
    
    var _executing : Bool = false {
        willSet {
            self.willChangeValueForKey("isExecuting")
        }
        didSet {
            self.didChangeValueForKey("isExecuting")
        }
    }
    
    override var executing: Bool {
        get {
            return _executing
        }
    }
    
    var _finished : Bool = false {
        willSet {
            self.willChangeValueForKey("isFinished")
        }
        didSet {
            self.didChangeValueForKey("isFinished")
        }
    }
    
    override var finished: Bool {
        get {
            return _finished
        }
    }
    
    var _cancelled : Bool = false {
        willSet {
            self.willChangeValueForKey("isCancelled")
        }
        didSet {
            self.didChangeValueForKey("isCancelled")
        }
    }
    
    override var cancelled: Bool {
        get {
            return _cancelled
        }
    }

    override func start() {
        assert(!_executing)
        self._executing = true
    }

    override func cancel() {
        _cancelled = true
        finish()
    }
    
    /// Mark the operation as finished.
    func finish() {
        _executing = false
        _finished = true
    }
}
