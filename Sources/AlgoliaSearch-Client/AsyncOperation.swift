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
/// This class provides its subclasses the way to manually control `Operation`'s standard properties:
///
/// - `executing`
/// - `finished`
/// - `cancel`
///
internal class AsyncOperation: Operation {
  // Mark this operation as aynchronous.
  override var isAsynchronous: Bool {
    return true
  }

  // NOTE: Overriding `Operation`'s properties
  // -----------------------------------------
  // These properties are defined as read-only by `Operation`. As a consequence, they must be computed properties.
  // But they must also fire KVO notifications, which are crucial for `OperationQueue` to work.
  // This is why we use a private (underscore-prefixed) property to store the state.

  var _executing: Bool = false {
    willSet {
      self.willChangeValue(forKey: "isExecuting")
    }
    didSet {
      self.didChangeValue(forKey: "isExecuting")
    }
  }

  override var isExecuting: Bool {
    return _executing
  }

  var _finished: Bool = false {
    willSet {
      self.willChangeValue(forKey: "isFinished")
    }
    didSet {
      self.didChangeValue(forKey: "isFinished")
    }
  }

  override var isFinished: Bool {
    return _finished
  }

  var _cancelled: Bool = false {
    willSet {
      self.willChangeValue(forKey: "isCancelled")
    }
    didSet {
      self.didChangeValue(forKey: "isCancelled")
    }
  }

  override var isCancelled: Bool {
    return _cancelled
  }

  override func start() {
    assert(!_executing)
    _executing = true
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

/// A specific type of async operation with a completion handler.
///
internal class AsyncOperationWithCompletion: AsyncOperation {
  /// User completion block to be called.
  let completion: CompletionHandler?

  /// Operation queue used to execute the completion handler.
  weak var completionQueue: OperationQueue?

  init(completionHandler: CompletionHandler?) {
    completion = completionHandler
  }

  override func start() {
    // The completion queue should not be the same as this operation's queue, otherwise a deadlock will result.
    assert(OperationQueue.current != completionQueue)
  }

  /// Finish this operation.
  /// This method should be called exactly once per operation.
  internal func callCompletion(content: [String: Any]?, error: Error?) {
    if _cancelled {
      return
    }
    if let completionQueue = completionQueue {
      completionQueue.addOperation {
        self._callCompletion(content: content, error: error)
      }
    } else {
      _callCompletion(content: content, error: error)
    }
  }

  internal func _callCompletion(content: [String: Any]?, error: Error?) {
    // WARNING: In case of asynchronous dispatch, the request could have been cancelled in the meantime
    // => check again.
    if !_cancelled {
      if let completion = completion {
        completion(content, error)
      }
      finish()
    }
  }
}

/// An asynchronous operation whose body is specified as a block.
///
internal class AsyncBlockOperation: AsyncOperationWithCompletion {
  typealias OperationBlock = () -> (content: [String: Any]?, error: Error?)

  /// The block that will be executed as part of the operation.
  let block: OperationBlock

  internal init(completionHandler: CompletionHandler?, block: @escaping OperationBlock) {
    self.block = block
    super.init(completionHandler: completionHandler)
  }

  /// Start this request.
  override func start() {
    super.start()
    let (content, error) = block()
    callCompletion(content: content, error: error)
  }
}
