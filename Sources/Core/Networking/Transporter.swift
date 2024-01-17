// APIs.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

open class Transporter {

  let configuration: Configuration
  let retryStrategy: RetryStrategy
  let requestBuilder: RequestBuilder

  public init(
    configuration: Configuration,
    retryStrategy: RetryStrategy? = nil,
    requestBuilder: RequestBuilder? = nil
  ) {
    self.configuration = configuration
    self.retryStrategy = retryStrategy ?? AlgoliaRetryStrategy(configuration: configuration)

    guard let requestBuilder = requestBuilder else {

      let sessionConfiguration: URLSessionConfiguration = .default

      sessionConfiguration.timeoutIntervalForRequest = configuration.readTimeout
      sessionConfiguration.timeoutIntervalForResource = configuration.writeTimeout

      self.requestBuilder =
        requestBuilder
        ?? URLSessionRequestBuilder(
          sessionConfiguration: sessionConfiguration
        )

      return
    }

    self.requestBuilder = requestBuilder
  }

  public func send<T: Decodable>(
    method: String, path: String, data: Codable?, requestOptions: RequestOptions? = nil,
    useReadTransporter: Bool = false
  ) async throws -> Response<T> {
    let httpMethod = HTTPMethod(rawValue: method)

    guard let httpMethod = httpMethod else {
      throw TransportError.requestError(AlgoliaError(errorMessage: "Unknown HTTP method"))
    }

    let callType = httpMethod.toCallType()
    let hostIterator = self.retryStrategy.retryableHosts(for: callType)

    let queryItems: [URLQueryItem] = requestOptions?.queryItems ?? []
    let headers: [String: String] = requestOptions?.headers ?? [:]
    var body: Data? = nil

    if let requestOptionsData = requestOptions?.body {
      body = try JSONSerialization.data(withJSONObject: requestOptionsData as Any, options: [])
    } else if let data = data {
      body = try CodableHelper.jsonEncoder.encode(data)
    }

    var urlComponents = URLComponents()

    urlComponents = urlComponents.set(\.path, to: path)
    urlComponents = urlComponents.set(\.queryItems, to: queryItems)

    if callType == CallType.read || useReadTransporter {
      if let body = body {
        let bodyDictionary: [String: Any?]? =
          try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any?]
        let bodyQueryItems: [URLQueryItem]? = APIHelper.mapValuesToQueryItems(bodyDictionary)
        if let bodyQueryItems = bodyQueryItems {
          urlComponents.queryItems?.append(contentsOf: bodyQueryItems)
        }
      }
    }

    var intermediateErrors: [Error] = []

    while let host = hostIterator.next() {

      let rawTimeout =
        requestOptions?.timeout(for: callType) ?? self.configuration.timeout(for: callType)
      let timeout = TimeInterval(host.retryCount + 1) * rawTimeout

      guard let url = urlComponents.url(relativeTo: host.url) else {
        throw TransportError.requestError(AlgoliaError(errorMessage: "Malformed URL"))
      }

      var request = URLRequest(url: url)

      request = request.set(\.httpMethod, to: httpMethod.rawValue)
      request = request.set(\.timeoutInterval, to: timeout)

      buildHeaders(with: headers).forEach { key, value in
        request.setValue(value, forHTTPHeaderField: key)
      }

      if callType == CallType.write && !useReadTransporter {
        let contentType = headers["Content-Type"] ?? "application/json"

        if contentType.hasPrefix("application/json") {
          request = request.set(\.httpBody, to: body)
        } else {
          throw TransportError.requestError(
            AlgoliaError(errorMessage: "Unsupported Media Type - \(contentType)"))
        }
      }

      do {
        let response: Response<T> = try await self.requestBuilder.execute(
          urlRequest: request, timeout: timeout)
        self.retryStrategy.notify(host: host, error: nil)
        return response
      } catch let cancellationError as CancellationError {
        throw TransportError.requestError(cancellationError)
      } catch {
        intermediateErrors.append(error)
        self.retryStrategy.notify(host: host, error: error)

        guard self.retryStrategy.canRetry(inCaseOf: error) else {
          break
        }
      }

    }

    throw TransportError.noReachableHosts(intermediateErrors: intermediateErrors)
  }

  private func buildHeaders(with requestHeaders: [String: String]) -> [String: String] {
    var httpHeaders: [String: String] = [:]
    for (key, value) in self.configuration.defaultHeaders ?? [:] {
      httpHeaders[key] = value
    }
    httpHeaders["User-Agent"] = UserAgentController.httpHeaderValue
    for (key, value) in requestHeaders {
      httpHeaders[key] = value
    }
    return httpHeaders
  }
}
