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
    tryLaunch(request: request)
  }

  // swiftlint:disable cyclomatic_complexity function_body_length
  private func tryLaunch(request: URLRequest) {

    guard !isCancelled else {
      Logger.loggingService.log(level: .debug, message: "Request was cancelled")
      return
    }

    guard let host = hostIterator.next() else {
      Logger.loggingService.log(level: .debug, message: "Request failed. No available host found.")
      result = .failure(HTTPTransport.Error.noReachableHosts)
      return
    }

    do {

      let effectiveRequest = try HostSwitcher.switchHost(in: request, by: host, timeout: timeout)

      if let url = effectiveRequest.url, let method = effectiveRequest.httpMethod {
        Logger.loggingService.log(level: .debug, message: "\(method): \(url)")
      }

      if let headers = effectiveRequest.allHTTPHeaderFields {
        Logger.loggingService.log(level: .debug, message: "Headers: \(headers)")
      }

      if let bodyData = effectiveRequest.httpBody {
        if let json = try? JSONDecoder().decode(JSON.self, from: bodyData) {
          Logger.loggingService.log(level: .debug, message: "Body: \(json)")
        } else {
          Logger.loggingService.log(level: .debug, message: "Body: data (\(bodyData.count) bytes)")
        }
      }

      underlyingTask = requester.perform(request: effectiveRequest) { [weak self] (result: IntermediateResult) in
        guard let httpRequest = self else { return }

        let retryOutcome = httpRequest.retryStrategy.notify(host: host, result: result)

        switch retryOutcome {
        case .retry:
          Logger.loggingService.log(level: .debug, message: "Request failed. Retry.")
          httpRequest.tryLaunch(request: request)

        case .success(let value):
          let output = httpRequest.transform(value)
          httpRequest.result = .success(output)

        case .failure(let error):
          Logger.loggingService.log(level: .debug, message: "Error: \(error)")
          httpRequest.result = .failure(error)
        }
      }

    } catch let error {
      switch error {
      case HostSwitcher.Error.badHost(let host):
        Logger.loggingService.log(level: .error, message: "Bad host: \(host). Will retry with next host. Please contact support@algolia.com if this problem occurs.")
        assertionFailure("Bad host: \(host)")
        tryLaunch(request: request)

      case HostSwitcher.Error.missingURL:
        Logger.loggingService.log(level: .error, message: "Command's request doesn't contain URL. Please contact support@algolia.com if this problem occurs.")
        assertionFailure("Command's request doesn't contain URL")
        result = .failure(error)

      case HostSwitcher.Error.malformedURL(let url):
        assertionFailure("Command's request URL is malformed: \(url). Please contact support@algolia.com if this problem occurs.")
        result = .failure(error)

      default:
        result = .failure(error)
      }
    }

  }

  override func cancel() {
    super.cancel()
    underlyingTask?.cancel()
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
