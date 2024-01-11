// URLSessionImplementations.swift
//
// Created by Algolia on 08/01/2024.
//

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
#if !os(macOS) && !os(Linux)
  import MobileCoreServices
#endif

public protocol URLSessionProtocol {
  func dataTask(
    with request: URLRequest,
    completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

public class URLSessionRequestBuilderFactory: RequestBuilderFactory {
  public func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
    return URLSessionRequestBuilder<T>.self
  }

  public func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
    return URLSessionDecodableRequestBuilder<T>.self
  }
}

public typealias AlgoliaSearchClientAPIChallengeHandler = (
  (URLSession, URLSessionTask, URLAuthenticationChallenge) -> (
    URLSession.AuthChallengeDisposition, URLCredential?
  )
)

// Store the URLSession's delegate to retain its reference
private let sessionDelegate = SessionDelegate()

// Store the URLSession to retain its reference
private let defaultURLSession = URLSession(
  configuration: .default, delegate: sessionDelegate, delegateQueue: nil)

// Store current taskDidReceiveChallenge for every URLSessionTask
private var challengeHandlerStore = SynchronizedDictionary<
  Int, AlgoliaSearchClientAPIChallengeHandler
>()

// Store current URLCredential for every URLSessionTask
private var credentialStore = SynchronizedDictionary<Int, URLCredential>()

open class URLSessionRequestBuilder<T>: RequestBuilder<T> {

  /**
     May be assigned if you want to control the authentication challenges.
     */
  public var taskDidReceiveChallenge: AlgoliaSearchClientAPIChallengeHandler?

  required public init(
    method: String, path: String, queryItems: [URLQueryItem]?, parameters: [String: Any]?,
    headers: [String: String] = [:],
    requiresAuthentication: Bool, transporter: Transporter
  ) {
    super.init(
      method: method, path: path, queryItems: queryItems, parameters: parameters, headers: headers,
      requiresAuthentication: requiresAuthentication, transporter: transporter)
  }

  /**
     May be overridden by a subclass if you want to control the URLSession
     configuration.
     */
  open func createURLSession() -> URLSessionProtocol {
    return defaultURLSession
  }

  /**
     May be overridden by a subclass if you want to control the URLRequest
     configuration (e.g. to override the cache policy).
     */
  open func createURLRequest(
    urlSession: URLSessionProtocol, method: HTTPMethod, host: RetryableHost?,
    encoding: ParameterEncoding,
    headers: [String: String]
  ) throws -> URLRequest {

    guard let url = URL(string: (host?.url.absoluteString ?? "") + path) else {
      throw URLRequest.FormatError.missingURL
    }

    var originalRequest = URLRequest(url: url)

    originalRequest.httpMethod = method.rawValue

    buildHeaders().forEach { key, value in
      originalRequest.setValue(value, forHTTPHeaderField: key)
    }

    let modifiedRequest = try encoding.encode(originalRequest, with: parameters)

    return modifiedRequest
  }

  @discardableResult
  override open func execute(
    _ apiResponseQueue: DispatchQueue = Transporter.apiResponseQueue,
    _ completion: @escaping (_ result: Swift.Result<Response<T>, ErrorResponse>) -> Void
  ) -> RequestTask {
    let urlSession = createURLSession()

    guard let xMethod = HTTPMethod(rawValue: method) else {
      fatalError("Unsupported Http method - \(method)")
    }

    let encoding: ParameterEncoding

    switch xMethod {
    case .get, .head:
      encoding = URLEncoding()

    case .options, .post, .put, .patch, .delete, .trace, .connect:
      let contentType = headers["Content-Type"] ?? "application/json"

      if contentType.hasPrefix("application/json") {
        encoding = JSONDataEncoding()
      } else {
        fatalError("Unsupported Media Type - \(contentType)")
      }
    }

    do {
      guard let host = hostIterator.next() else {
        let errorMessage = "No host available"
        Logger.loggingService.log(
          level: self.transporter.configuration.logLevel, message: errorMessage)
        throw URLRequest.FormatError.missingURL
      }

      let request = try createURLRequest(
        urlSession: urlSession, method: xMethod, host: host, encoding: encoding, headers: headers)

      var taskIdentifier: Int?
      let cleanupRequest = {
        if let taskIdentifier = taskIdentifier {
          challengeHandlerStore[taskIdentifier] = nil
          credentialStore[taskIdentifier] = nil
        }
      }

      let retryableCompletion: (_ result: Swift.Result<Response<T>, ErrorResponse>) -> Void = {
        [weak self] result in
        guard let self = self else { return }

        switch result {
        case .success:
          // Call the original completion block for successful responses
          completion(result)

        case .failure(let error):
          self.transporter.retryStrategy.notify(host: host, result: result)

          if self.transporter.retryStrategy.canRetry(inCaseOf: error) {
            // Retry the request using the same function recursively

            guard let host = hostIterator.next() else {
              let errorMessage = "No host available"
              Logger.loggingService.log(
                level: self.transporter.configuration.logLevel, message: errorMessage)

              completion(
                .failure(
                  ErrorResponse.error(
                    .badRequest, nil, nil,
                    URLRequest.FormatError.missingURL)))
              return
            }
            do {
              try request.switchingHost(
                by: host,
                withBaseTimeout: self.transporter.configuration.timeout(for: xMethod.toCallType()))
            } catch {
              let errorMessage = "Unable to switch host"
              Logger.loggingService.log(
                level: self.transporter.configuration.logLevel, message: errorMessage)

              completion(
                .failure(
                  ErrorResponse.error(
                    .badRequest, nil, nil,
                    URLRequest.FormatError.missingURL)))
              return
            }

            let retryTask = self.execute(apiResponseQueue, completion)
            requestTask.set(task: retryTask)
          } else {
            // Call the original completion block for non-retryable errors
            completion(result)
          }
        }
      }

      let dataTask = urlSession.dataTask(with: request) { data, response, error in
        apiResponseQueue.async {
          self.processRequestResponse(
            urlRequest: request, data: data, response: response, error: error,
            completion: retryableCompletion)
          cleanupRequest()
        }
      }

      onProgressReady?(dataTask.progress)

      taskIdentifier = dataTask.taskIdentifier
      challengeHandlerStore[dataTask.taskIdentifier] = taskDidReceiveChallenge
      credentialStore[dataTask.taskIdentifier] = credential

      dataTask.resume()

      requestTask.set(task: dataTask)
    } catch {
      apiResponseQueue.async {
        completion(.failure(ErrorResponse.error(415, nil, nil, error)))
      }
    }

    return requestTask
  }

  fileprivate func processRequestResponse(
    urlRequest: URLRequest, data: Data?, response: URLResponse?, error: Error?,
    completion: @escaping (_ result: Swift.Result<Response<T>, ErrorResponse>) -> Void
  ) {

    if let error = error {
      completion(.failure(ErrorResponse.error(-1, data, response, error)))
      return
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      completion(
        .failure(
          ErrorResponse.error(-2, data, response, DecodableRequestBuilderError.nilHTTPResponse)))
      return
    }

    guard httpResponse.isStatusCodeSuccessful else {
      completion(
        .failure(
          ErrorResponse.error(
            httpResponse.statusCode, data, response,
            DecodableRequestBuilderError.unsuccessfulHTTPStatusCode)))
      return
    }

    switch T.self {
    case is Void.Type:

      completion(.success(Response(response: httpResponse, body: () as! T, bodyData: data)))

    default:
      fatalError("Unsupported Response Body Type - \(String(describing: T.self))")
    }

  }

  open func buildHeaders() -> [String: String] {
    var httpHeaders: [String: String] = [:]
    for (key, value) in Transporter.customHeaders {
      httpHeaders[key] = value
    }
    for (key, value) in self.transporter.configuration.defaultHeaders ?? [:] {
      httpHeaders[key] = value
    }
    httpHeaders["User-Agent"] = UserAgentController.httpHeaderValue
    for (key, value) in headers {
      httpHeaders[key] = value
    }
    return httpHeaders
  }
}

open class URLSessionDecodableRequestBuilder<T: Decodable>: URLSessionRequestBuilder<T> {
  override open func createURLRequest(
    urlSession: URLSessionProtocol, method: HTTPMethod, host: RetryableHost?,
    encoding: ParameterEncoding,
    headers: [String: String]
  ) throws -> URLRequest {
    var superReq = try super.createURLRequest(
      urlSession: urlSession, method: method, host: host, encoding: encoding, headers: headers)
    superReq.timeoutInterval = self.transporter.configuration.timeout(for: method.toCallType())

    guard let url = superReq.url else { throw URLRequest.FormatError.missingURL }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      throw URLRequest.FormatError.malformedURL(url.absoluteString)
    }
    guard let urlWithQueryItems = components.set(\.queryItems, to: queryItems).url else {
      throw URLRequest.FormatError.invalidQueryItems
    }

    return superReq.setIfNotNil(\.url, to: urlWithQueryItems)
  }

  override fileprivate func processRequestResponse(
    urlRequest: URLRequest, data: Data?, response: URLResponse?, error: Error?,
    completion: @escaping (_ result: Swift.Result<Response<T>, ErrorResponse>) -> Void
  ) {

    if let error = error {
      completion(.failure(ErrorResponse.error(-1, data, response, error)))
      return
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      completion(
        .failure(
          ErrorResponse.error(-2, data, response, DecodableRequestBuilderError.nilHTTPResponse)))
      return
    }

    guard httpResponse.isStatusCodeSuccessful else {
      completion(
        .failure(
          ErrorResponse.error(
            httpResponse.statusCode, data, response,
            DecodableRequestBuilderError.unsuccessfulHTTPStatusCode)))
      return
    }

    switch T.self {
    case is String.Type:

      let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""

      completion(.success(Response<T>(response: httpResponse, body: body as! T, bodyData: data)))

    case is Void.Type:

      completion(.success(Response(response: httpResponse, body: () as! T, bodyData: data)))

    case is Data.Type:

      completion(.success(Response(response: httpResponse, body: data as! T, bodyData: data)))

    default:

      guard let unwrappedData = data, !unwrappedData.isEmpty else {
        if let expressibleByNilLiteralType = T.self as? ExpressibleByNilLiteral.Type {
          completion(
            .success(
              Response(
                response: httpResponse,
                body: expressibleByNilLiteralType.init(nilLiteral: ()) as! T, bodyData: data)))
        } else {
          completion(
            .failure(
              ErrorResponse.error(
                httpResponse.statusCode, nil, response,
                DecodableRequestBuilderError.emptyDataResponse)))
        }
        return
      }

      let decodeResult = CodableHelper.decode(T.self, from: unwrappedData)

      switch decodeResult {
      case let .success(decodableObj):
        completion(
          .success(Response(response: httpResponse, body: decodableObj, bodyData: unwrappedData)))
      case let .failure(error):
        completion(
          .failure(ErrorResponse.error(httpResponse.statusCode, unwrappedData, response, error)))
      }
    }
  }
}

private class SessionDelegate: NSObject, URLSessionTaskDelegate {
  func urlSession(
    _ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {

    var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling

    var credential: URLCredential?

    if let taskDidReceiveChallenge = challengeHandlerStore[task.taskIdentifier] {
      (disposition, credential) = taskDidReceiveChallenge(session, task, challenge)
    } else {
      if challenge.previousFailureCount > 0 {
        disposition = .rejectProtectionSpace
      } else {
        credential =
          credentialStore[task.taskIdentifier]
          ?? session.configuration.urlCredentialStorage?.defaultCredential(
            for: challenge.protectionSpace)

        if credential != nil {
          disposition = .useCredential
        }
      }
    }

    completionHandler(disposition, credential)
  }
}

public enum HTTPMethod: String {
  case options = "OPTIONS"
  case get = "GET"
  case head = "HEAD"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
  case trace = "TRACE"
  case connect = "CONNECT"
}

public protocol ParameterEncoding {
  func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest
}

private class URLEncoding: ParameterEncoding {
  func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {

    var urlRequest = urlRequest

    guard let parameters = parameters else { return urlRequest }

    guard let url = urlRequest.url else {
      throw DownloadException.requestMissingURL
    }

    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
      !parameters.isEmpty
    {
      urlComponents.queryItems = APIHelper.mapValuesToQueryItems(parameters)
      urlRequest.url = urlComponents.url
    }

    return urlRequest
  }
}

extension Data {
  /// Append string to Data
  ///
  /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to Data, and then add that data to the Data, this wraps it in a nice convenient little extension to Data. This converts using UTF-8.
  ///
  /// - parameter string:       The string to be added to the `Data`.

  fileprivate mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }
}

extension Optional where Wrapped == Data {
  fileprivate var orEmpty: Data {
    self ?? Data()
  }
}

extension JSONDataEncoding: ParameterEncoding {}
