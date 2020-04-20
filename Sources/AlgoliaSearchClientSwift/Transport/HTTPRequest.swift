//
//  HTTPRequest.swift
//  
//
//  Created by Vladislav Fitc on 02/04/2020.
//

import Foundation

class HTTPRequest<ResponseType: Codable, Output>: AsyncOperation, ResultContainer, TransportTask {

  typealias Transform = (ResponseType) -> Output
  typealias IntermediateResult = Swift.Result<ResponseType, Swift.Error>
  typealias Result = Swift.Result<Output, Swift.Error>

  let requester: HTTPRequester
  let hostIterator: HostIterator
  let retryStrategy: RetryStrategy
  let timeout: TimeInterval
  let request: URLRequest
  let transform: (ResponseType) -> Output
  let completion: (Result) -> Void
  var didUpdateProgress: ((ProgressReporting) -> Void)?

  var underlyingTask: (TransportTask)? {
    didSet {
      guard let task = self.underlyingTask else { return }
      didUpdateProgress?(task)
    }
  }

  var result: Result? {
    didSet {
      guard let result = self.result else { return }
      self.completion(result)
      self.state = .finished
    }
  }

  var progress: Progress {
    return underlyingTask?.progress ?? Progress()
  }

  init(requester: HTTPRequester,
       retryStrategy: RetryStrategy,
       hostIterator: HostIterator,
       request: URLRequest,
       timeout: TimeInterval,
       transform: @escaping Transform,
       completion: @escaping (Result) -> Void) {
    self.requester = requester
    self.retryStrategy = retryStrategy
    self.hostIterator = hostIterator
    self.request = request
    self.timeout = timeout
    self.transform = transform
    self.completion = completion
    self.underlyingTask = nil
  }

  override func main() {
    tryLaunch(request: request)
  }

  private func tryLaunch(request: URLRequest) {

    guard !isCancelled else {
      return
    }

    guard let host = hostIterator.next() else {
      result = .failure(HttpTransport.Error.noReachableHosts)
      return
    }

    do {

      let effectiveRequest = try HostSwitcher.switchHost(in: request, by: host, timeout: timeout)

      underlyingTask = requester.perform(request: effectiveRequest) { [weak self] (result: IntermediateResult) in
        guard let httpRequest = self else { return }

        let retryOutcome = httpRequest.retryStrategy.notify(host: host, result: result)

        switch retryOutcome {
        case .retry:
          httpRequest.tryLaunch(request: request)

        case .success(let value):
          let output = httpRequest.transform(value)
          httpRequest.result = .success(output)

        case .failure(let error):
          httpRequest.result = .failure(error)
        }
      }

    } catch let error {
      switch error {
      case HostSwitcher.Error.badHost(let host):
        assertionFailure("Bad host: \(host)")
        tryLaunch(request: request)

      case HostSwitcher.Error.missingURL:
        assertionFailure("Command's request doesn't contain URL")
        result = .failure(error)

      case HostSwitcher.Error.malformedURL(let url):
        assertionFailure("Command's request URL is malformed: \(url)")
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
       timeout: TimeInterval,
       completion: @escaping (Result) -> Void) {
    self.init(requester: requester,
              retryStrategy: retryStrategy,
              hostIterator: hostIterator,
              request: request,
              timeout: timeout,
              transform: { $0 },
              completion: completion)
  }

  
}
