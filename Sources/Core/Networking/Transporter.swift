// Transporter.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation
import Gzip

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: - Transporter

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

        guard let requestBuilder else {
            let sessionConfiguration: URLSessionConfiguration = .default

            sessionConfiguration.timeoutIntervalForRequest = configuration.readTimeout
            sessionConfiguration.timeoutIntervalForResource = configuration.writeTimeout

            self.requestBuilder = URLSessionRequestBuilder(
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

        guard let httpMethod else {
            throw AlgoliaError.requestError(GenericError(description: "Unknown HTTP method"))
        }

        let callType: CallType = useReadTransporter ? CallType.read : httpMethod.toCallType()
        let hostIterator: HostIterator = self.retryStrategy.retryableHosts(for: callType)
        let headers: [String: String] = requestOptions?.headers ?? [:]
        var body: Data? = nil
        var urlComponents = URLComponents()
        var intermediateErrors: [Error] = []

        if let requestOptionsData = requestOptions?.body {
            body = try JSONSerialization.data(withJSONObject: requestOptionsData as Any, options: [])
        } else if let data {
            body = try CodableHelper.jsonEncoder.encode(data)
        }

        if httpMethod == .get {
            body = nil
        } else if body == nil, httpMethod != .delete {
            body = "{}".data(using: .utf8)
        }

        urlComponents.percentEncodedPath = path

        if let percentEncodedQueryItems = APIHelper.mapValuesToQueryItems(requestOptions?.queryParameters) {
            urlComponents.percentEncodedQueryItems = percentEncodedQueryItems
        }

        while let host = hostIterator.next() {
            let rawTimeout =
                requestOptions?.timeout(for: callType) ?? self.configuration.timeout(for: callType)
            let timeout = TimeInterval(host.retryCount + 1) * rawTimeout

            guard let url = urlComponents.url(relativeTo: host.url) else {
                throw AlgoliaError.requestError(GenericError(description: "Malformed URL"))
            }

            var request = URLRequest(url: url)

            request.httpMethod = httpMethod.rawValue
            request.timeoutInterval = timeout

            for (key, value) in self.configuration.defaultHeaders ?? [:] {
                request.setValue(value, forHTTPHeaderField: key.capitalized)
            }
            request.setValue(
                UserAgentController.httpHeaderValue, forHTTPHeaderField: "User-Agent".capitalized
            )
            if self.configuration.compression == .gzip {
                request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding".capitalized)

                if let bodyData = body {
                    request.setValue("gzip", forHTTPHeaderField: "Content-Encoding".capitalized)

                    body = try bodyData.gzipped()
                }
            }
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key.capitalized)
            }

            if callType == CallType.write {
                guard let contentType = request.allHTTPHeaderFields?["Content-Type"],
                      contentType.hasPrefix("application/json")
                else {
                    throw AlgoliaError.requestError(
                        GenericError(description: "Unsupported Content-Type")
                    )
                }
            }

            request.httpBody = body

            do {
                let response: Response<T> = try await requestBuilder.execute(
                    urlRequest: request, timeout: timeout
                )
                self.retryStrategy.notify(host: host, error: nil)
                return response
            } catch let cancellationError as CancellationError {
                throw cancellationError
            } catch {
                self.retryStrategy.notify(host: host, error: error)

                guard self.retryStrategy.canRetry(inCaseOf: error) else {
                    throw AlgoliaError.requestError(error)
                }

                intermediateErrors.append(error)
            }
        }

        throw AlgoliaError.noReachableHosts(intermediateErrors: intermediateErrors)
    }
}
