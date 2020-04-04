//
//  HTTPRequest.swift
//  
//
//  Created by Vladislav Fitc on 02/04/2020.
//

import Foundation

class HTTPRequest<Value: Codable>: AsyncOperation, ResultContainer, TransportTask {
  
  typealias Result = Swift.Result<Value, Swift.Error>
  
  let requester: HTTPRequester
  let hostIterator: HostIterator
  let retryStrategyContainer: RetryStrategyContainer
  let timeout: TimeInterval
  let request: URLRequest
  let completion: (ResultCallback<Value>)
  var didUpdateProgress: ((ProgressReporting) -> ())?
  
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
       retryStrategyContainer: RetryStrategyContainer,
       hostIterator: HostIterator,
       request: URLRequest,
       timeout: TimeInterval,
       completion: @escaping ResultCallback<Value>) {
    self.requester = requester
    self.retryStrategyContainer = retryStrategyContainer
    self.hostIterator = hostIterator
    self.request = request
    self.timeout = timeout
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
      
      underlyingTask = requester.perform(request: effectiveRequest) { [weak self] (result: Result) in
        guard let httpRequest = self else { return }
        
        let retryOutcome = httpRequest.retryStrategyContainer.retryStrategy.notify(host: host, result: result)
        
        switch retryOutcome {
        case .retry:
          httpRequest.tryLaunch(request: request)
          
        case .success(let value):
          httpRequest.result = .success(value)
          
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
