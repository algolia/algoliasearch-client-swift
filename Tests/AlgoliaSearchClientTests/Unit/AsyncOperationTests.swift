import XCTest
@testable import AlgoliaSearchClient

final class AsyncOperationTests: XCTestCase {

  class TestOperation: AsyncOperation {
    override func main() {
      work()
    }

    private func work() {
      DispatchQueue.global().asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(200)) {
        self.state = .finished
      }
    }
  }

  func testCancellation_withoutQueue() {
    let operation = TestOperation()
    XCTAssertTrue(operation.isReady)
    operation.cancel()
    XCTAssertTrue(operation.isCancelled)
    operation.start()
    XCTAssertTrue(operation.isFinished)
  }

  func testCancellation_updatesIsCancelled_whenCancelledBeforeEnqueuing() {
    let operation = TestOperation()
    let queue = OperationQueue()
    operation.cancel()
    queue.addOperation(operation)
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertTrue(operation.isCancelled)
    XCTAssertTrue(operation.isFinished)
  }

  func testCancellation_updatesIsCancelled_whenCancelledAfterEnqueuing() {
    let operation = TestOperation()
    let queue = OperationQueue()
    queue.addOperation(operation)
    operation.cancel()
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertTrue(operation.isCancelled)
    XCTAssertTrue(operation.isFinished)
  }

  func testCancellation_updatesIsCancelled_whenOperationIsRunning() {
    let queue = OperationQueue()
    let operation = TestOperation()
    queue.addOperation(operation)
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertTrue(operation.isExecuting)
    operation.cancel()
    XCTAssertFalse(operation.isFinished)
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertTrue(operation.isCancelled)
    XCTAssertTrue(operation.isFinished)
  }

  func testCancellation_ignoresCancellation_whenOperationIsFinished() {
    let queue = OperationQueue()
    let operation = TestOperation()
    queue.addOperation(operation)
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertTrue(operation.isFinished)
    operation.cancel()
    XCTAssertFalse(operation.isCancelled)
  }

   // Behavior of standard Operation without subclassing.
  func testCancellation_ofBlockOperation_withoutQueue() {
    let operation = BlockOperation {
      Thread.sleep(forTimeInterval: 0.1)
    }
    XCTAssertTrue(operation.isReady)
    operation.cancel()
    XCTAssertTrue(operation.isCancelled)
    operation.start()
    XCTAssertTrue(operation.isFinished)
  }

  func testCancellation_ofBlockOperation_updatesIsCancelled_whenCancelledBeforeEnqueuing() {
    let operation = BlockOperation {
      Thread.sleep(forTimeInterval: 0.1)
    }
    let queue = OperationQueue()
    operation.cancel()
    queue.addOperation(operation)
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertTrue(operation.isCancelled)
    XCTAssertTrue(operation.isFinished)
  }

  func testCancellation_ofBlockOperation_updatesIsCancelled_whenCancelledAfterEnqueuing() {
    let operation = BlockOperation {
      Thread.sleep(forTimeInterval: 0.1)
    }
    let queue = OperationQueue()
    queue.addOperation(operation)
    operation.cancel()
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertTrue(operation.isCancelled)
    XCTAssertTrue(operation.isFinished)
  }

  func testCancellation_ofBlockOperation_updatesIsCancelled_whenOperationIsRunning() {
    let queue = OperationQueue()
    let operation = BlockOperation {
      Thread.sleep(forTimeInterval: 0.2)
    }
    queue.addOperation(operation)
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssertTrue(operation.isExecuting)
    operation.cancel()
    XCTAssertFalse(operation.isFinished)
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertTrue(operation.isCancelled)
    XCTAssertTrue(operation.isFinished)
  }

  func testCancellation_ofBlockOperation_ignoresCancellation_whenOperationIsFinished() {
    let queue = OperationQueue()
    let operation = BlockOperation {
      Thread.sleep(forTimeInterval: 0.1)
    }
    queue.addOperation(operation)
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertTrue(operation.isFinished)
    operation.cancel()
    XCTAssertFalse(operation.isCancelled)
  }

}
