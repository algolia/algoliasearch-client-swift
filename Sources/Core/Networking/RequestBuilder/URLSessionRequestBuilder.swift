//
//  URLSessionRequestBuilder.swift
//
//
//  Created by Algolia on 16/01/2024.
//

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

open class URLSessionRequestBuilder: RequestBuilder {

  private(set) var sessionManager: URLSession

  required public init() {
    let sessionConfiguration: URLSessionConfiguration = .default

    self.sessionManager = URLSession(configuration: sessionConfiguration)
  }

  public init(
    sessionConfiguration: URLSessionConfiguration
  ) {
    self.sessionManager = URLSession(configuration: sessionConfiguration)
  }

  @discardableResult
  open func execute<T: Decodable>(urlRequest: URLRequest, timeout: TimeInterval) async throws
    -> Response<T>
  {
    self.sessionManager.configuration.timeoutIntervalForResource = timeout

    var (responseData, httpResponse): (Data?, URLResponse?) = (nil, nil)
    do {
      #if canImport(FoundationNetworking)
        (responseData, httpResponse) = try await self.sessionManager.asyncData(for: urlRequest)
      #else
        (responseData, httpResponse) = try await self.sessionManager.data(for: urlRequest)
      #endif
    } catch {
      throw TransportError.requestError(error)
    }

    return try await self.processRequestResponse(
      urlRequest: urlRequest, data: responseData, response: httpResponse)
  }

  fileprivate func processRequestResponse<T: Decodable>(
    urlRequest: URLRequest, data: Data?, response: URLResponse?
  ) async throws -> Response<T> {

    guard let httpResponse = response as? HTTPURLResponse else {
      throw TransportError.decodingFailure(
        AlgoliaError(errorMessage: "Unable to decode HTTPURLResponse"))
    }

    // This initializer returns `nil` if the HTTP response status code is in the successful range
    if let httpError = HTTPError(response: httpResponse, data: data) {
      throw TransportError.httpError(httpError)
    }

    switch T.self {

    case is String.Type:
      let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
      return Response<T>(response: httpResponse, body: body as! T, bodyData: data)

    case is Void.Type:
      return Response(response: httpResponse, body: () as! T, bodyData: data)

    case is Data.Type:
      return Response(response: httpResponse, body: data as! T, bodyData: data)

    default:
      guard let unwrappedData = data, !unwrappedData.isEmpty else {
        if let expressibleByNilLiteralType = T.self as? ExpressibleByNilLiteral.Type {
          return Response(
            response: httpResponse,
            body: expressibleByNilLiteralType.init(nilLiteral: ()) as! T, bodyData: data)
        } else {
          throw TransportError.missingData
        }
      }

      let decodeResult = CodableHelper.decode(T.self, from: unwrappedData)

      switch decodeResult {
      case let .success(decodableObj):
        return Response(response: httpResponse, body: decodableObj, bodyData: unwrappedData)
      case let .failure(error):
        throw TransportError.decodingFailure(
          AlgoliaError(
            errorMessage: "Unable to decode response decodable object: "
              + error.localizedDescription))
      }
    }
  }
}
