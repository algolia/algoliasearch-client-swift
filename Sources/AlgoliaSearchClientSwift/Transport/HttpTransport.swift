//
//  HttpTransport.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

extension Encodable {
  
  var httpBody: Data {
    let jsonEncoder = JSONEncoder()
    do {
      let body = try jsonEncoder.encode(self)
      return body
    } catch let error {
      assertionFailure("\(error)")
      return Data()
    }
  }
  
}



/**
 The transport layer is responsible of the serialization/deserialization and the retry strategy.
*/
class HttpTransport: Transport, RetryStrategyContainer {
  
  let session: URLSession
  var configuration: Configuration
  var retryStrategy: RetryStrategy
  let credentials: Credentials?

  init(configuration: Configuration,
       credentials: Credentials? = nil,
       retryStrategy: RetryStrategy? = nil) {
    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders
    session = .init(configuration: .default)
    self.configuration = configuration
    self.credentials = credentials
    self.retryStrategy = retryStrategy ?? AlgoliaRetryStrategy(configuration: configuration)
  }
  
  public func request<T: Codable>(method: HttpMethod,
                                  callType: CallType,
                                  path: String,
                                  body: Data?,
                                  requestOptions: RequestOptions?,
                                  completion: @escaping ResultCallback<T>) {
    
    let hostIterator = HostIterator(container: self, callType: callType)
        
    let requestTemplate = URLRequest(method: method,
                                     path: path,
                                     callType: callType,
                                     body: body,
                                     requestOptions: requestOptions,
                                     credentials: credentials,
                                     configuration: configuration)
    
    request(requestTemplate, hostIterator: hostIterator, completion: completion)
  }
  
  private func request<T: Codable>(_ request: URLRequest,
                                   hostIterator: HostIterator,
                                   completion: @escaping ResultCallback<T>) {
    
    guard let host = hostIterator.next() else {
      completion(.failure(Error.noReachableHosts))
      return
    }
    
    let effectiveRequest = request.withHost(host)
    
    let task = session.dataTask(with: effectiveRequest) { [weak self] (data, response, error) in
      
      guard let transport = self else { return }
      
      let result = Result<T, Swift.Error>(data: data, response: response, error: error)
      
      do {
        let retryOutcome = try transport.retryStrategy.notify(host: host, result: result)
        
        switch retryOutcome {
        case .success:
          completion(result)
          
        case .retry:
          transport.request(request, hostIterator: hostIterator, completion: completion)
        }
      } catch let error {
        completion(.failure(error))
      }
      
    }
    
    task.resume()
    
  }
      
}
