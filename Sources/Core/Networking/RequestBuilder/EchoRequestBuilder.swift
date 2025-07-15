//
//  EchoRequestBuilder.swift
//
//
//  Created by Algolia on 12/01/2024.
//

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: - EchoResponse

public struct EchoResponse: Codable {
    let statusCode: HTTPStatusСode
    let method: HTTPMethod
    let url: String
    let timeout: TimeInterval
    let originalBodyData: Data?
    let path: String
    let host: String
    let algoliaAgent: String
    let queryParameters: [String: String?]?
    let headers: [String: String?]?
}

// MARK: - EchoRequestBuilder

final class EchoRequestBuilder: RequestBuilder {
    let statusCode: HTTPStatusСode

    init() {
        self.statusCode = 200
    }

    init(statusCode: HTTPStatusСode) {
        self.statusCode = statusCode
    }

    final func execute<T: Decodable>(urlRequest: URLRequest, timeout: TimeInterval) async throws
    -> Response<T> {
        let headers = urlRequest.allHTTPHeaderFields ?? [:]

        guard let requestHttpMethod = urlRequest.httpMethod,
              let httpMethod = HTTPMethod(rawValue: requestHttpMethod)
        else {
            throw AlgoliaError.requestError(
                GenericError(description: "Unable to parse HTTP method from request")
            )
        }

        guard let url = urlRequest.url else {
            throw AlgoliaError.requestError(
                GenericError(description: "Unable to parse URL from request")
            )
        }

        guard
            let mockHTTPURLResponse = HTTPURLResponse(
                url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil
            )
        else {
            throw AlgoliaError.requestError(
                GenericError(description: "Unable to mock HTTPURLResponse from EchoTransporter")
            )
        }

        let urlComponents = URLComponents(string: url.absoluteString)
        let queryParameters = self.processQueryItems(from: urlComponents?.percentEncodedQueryItems)

        let echoResponse = EchoResponse(
            statusCode: statusCode,
            method: httpMethod,
            url: url.absoluteString,
            timeout: timeout,
            originalBodyData: urlRequest.httpBody,
            path: urlComponents?.percentEncodedPath ?? "",
            host: url.host ?? "",
            algoliaAgent: headers["User-Agent"] ?? "",
            queryParameters: queryParameters,
            headers: headers
        )

        let interceptedBody = try CodableHelper.jsonEncoder.encode(echoResponse)

        return Response(response: mockHTTPURLResponse, body: nil, bodyData: interceptedBody)
    }

    fileprivate func processQueryItems(from queryItems: [URLQueryItem]?)
    -> [String: String?]? {
        guard let queryItems else {
            return nil
        }

        return queryItems.reduce(into: [String: String?]()) { acc, cur in
            acc.updateValue(cur.value, forKey: cur.name)
        }
    }
}
