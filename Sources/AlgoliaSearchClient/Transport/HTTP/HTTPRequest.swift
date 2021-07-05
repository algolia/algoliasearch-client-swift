//
//  HTTPRequest.swift
//  
//
//  Created by Vladislav Fitc on 02/04/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class HTTPRequest<ResponseType: Decodable, Output>: AsyncOperation, ResultContainer, TransportTask {

  typealias Transform = (ResponseType) -> Output
  typealias IntermediateResult = Swift.Result<ResponseType, Swift.Error>
  typealias Result = Swift.Result<Output, Swift.Error>

  let requester: HTTPRequester
  let retryStrategy: RetryStrategy
  let timeout: TimeInterval
  let request: URLRequest
  let callType: CallType
  let transform: (ResponseType) -> Output
  let completion: (Result) -> Void
  let hostIterator: HostIterator
  var didUpdateProgress: ((ProgressReporting) -> Void)?

  var underlyingTask: (TransportTask)? {
    didSet {
      guard let task = self.underlyingTask else { return }
      didUpdateProgress?(task)
    }
  }

  var result: Result = .failure(SyncOperationError.notFinished) {
    didSet {
      self.completion(result)
      self.state = .finished
    }
  }

  var progress: Progress {
    return underlyingTask?.progress ?? Progress(totalUnitCount: 1)
  }

  init(requester: HTTPRequester,
       retryStrategy: RetryStrategy,
       request: URLRequest,
       callType: CallType,
       timeout: TimeInterval,
       transform: @escaping Transform,
       completion: @escaping (Result) -> Void) {
    self.requester = requester
    self.retryStrategy = retryStrategy
    self.request = request
    self.callType = callType
    self.timeout = timeout
    self.transform = transform
    self.completion = completion
    self.underlyingTask = nil
    self.hostIterator = retryStrategy.retryableHosts(for: callType)
  }

  override func main() {
    tryLaunch(request: request, intermediateErrors: [])
  }

  private func tryLaunch(request: URLRequest, intermediateErrors: [Error]) {

    guard !isCancelled else {
      Logger.loggingService.log(level: .debug, message: "Request was cancelled")
      return
    }

    do {

      guard let host = hostIterator.next() else {
        throw HTTPTransport.Error.noReachableHosts(intermediateErrors: intermediateErrors)
      }

      let effectiveRequest = try request.setting(host, timeout: timeout)
      Logger.loggingService.log(level: .debug, message: description(for: effectiveRequest))

      underlyingTask = requester.perform(request: effectiveRequest) { [weak self] (result: IntermediateResult) in
        guard let httpRequest = self else { return }

        httpRequest.retryStrategy.notify(host: host, result: result)

        switch result {
        case .failure(let error) where httpRequest.retryStrategy.canRetry(inCaseOf: error):
          httpRequest.tryLaunch(request: request, intermediateErrors: intermediateErrors + [error])
        default:
          httpRequest.result = result.map(httpRequest.transform)
        }
      }

    } catch let error {
      Logger.loggingService.log(level: .debug, message: error.localizedDescription)
      if retryStrategy.canRetry(inCaseOf: error) {
        tryLaunch(request: request, intermediateErrors: intermediateErrors + [error])
      } else {
        result = .failure(error)
      }
    }

  }

  override func cancel() {
    super.cancel()
    underlyingTask?.cancel()
  }

  func description(for request: URLRequest) -> String {
    [
      "Method: \(request.httpMethod ?? "nil")",
      "URL: \(request.url?.description ?? "nil")",
      "Headers: \(request.allHTTPHeaderFields?.description ?? "nil")",
      "Body: \(request.httpBody.flatMap { $0.jsonString ?? $0.debugDescription } ?? "nil")"
    ].joined(separator: "\n")
  }

}

extension HTTPRequest where ResponseType == Output {

  convenience init(requester: HTTPRequester,
                   retryStrategy: RetryStrategy,
                   hostIterator: HostIterator,
                   request: URLRequest,
                   callType: CallType,
                   timeout: TimeInterval,
                   completion: @escaping (Result) -> Void) {
    self.init(requester: requester,
              retryStrategy: retryStrategy,
              request: request,
              callType: callType,
              timeout: timeout,
              transform: { $0 },
              completion: completion)
  }

}
