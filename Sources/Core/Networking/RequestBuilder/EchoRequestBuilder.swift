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

public struct EchoResponse: Codable {
    let statusCode: HTTPStatusСode
    let method: HTTPMethod
    let url: String
    let timeout: TimeInterval
    let originalBodyData: Data?
    let path: String
    let host: String
    let algoliaAgent: String
    let queryItems: [String: String?]?
    let headers: [String: String?]?
}

final class EchoRequestBuilder: RequestBuilder {
    let statusCode: HTTPStatusСode

    public init() {
        statusCode = 200
    }

    public init(statusCode: HTTPStatusСode) {
        self.statusCode = statusCode
    }

    final func execute<T: Decodable>(urlRequest: URLRequest, timeout: TimeInterval) async throws
        -> Response<T>
    {
        let headers = urlRequest.allHTTPHeaderFields ?? [:]

        guard let requestHttpMethod = urlRequest.httpMethod,
              let httpMethod = HTTPMethod(rawValue: requestHttpMethod)
        else {
            throw AlgoliaError.requestError(
                GenericError(description: "Unable to parse HTTP method from request"))
        }

        guard let url = urlRequest.url else {
            throw AlgoliaError.requestError(
                GenericError(description: "Unable to parse URL from request"))
        }

        guard
            let mockHTTPURLResponse = HTTPURLResponse(
                url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil
            )
        else {
            throw AlgoliaError.requestError(
                GenericError(description: "Unable to mock HTTPURLResponse from EchoTransporter"))
        }

        let queryItems = processQueryItems(from: url.query)

        let echoResponse = EchoResponse(
            statusCode: statusCode, method: httpMethod, url: url.absoluteString, timeout: timeout,
            originalBodyData: urlRequest.httpBody, path: url.path, host: url.host ?? "",
            algoliaAgent: headers["X-Algolia-Agent"] ?? "",
            queryItems: queryItems, headers: headers
        )

        let interceptedBody = try CodableHelper.jsonEncoder.encode(echoResponse)

        return Response(response: mockHTTPURLResponse, body: nil, bodyData: interceptedBody)
    }

    fileprivate func processQueryItems(from query: String?) -> [String: String?]? {
        guard let query = query else {
            return nil
        }

        let components = URLComponents(string: "?" + query)

        return components?.queryItems?.reduce(into: [String: String?]()) { acc, cur in
            acc.updateValue(cur.value, forKey: cur.name)
        }
    }
}
