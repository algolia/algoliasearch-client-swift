//
//  RequestOptions.swift
//
//
//  Created by Algolia on 11/01/2024.
//

import Foundation

public class RequestOptions {
    public init(
        headers: [String: String]? = nil,
        queryParameters: [String: Any?]? = nil,
        readTimeout: TimeInterval? = nil,
        writeTimeout: TimeInterval? = nil,
        body: [String: Any?]? = nil
    ) {
        self.headers = headers
        self.queryParameters = queryParameters
        self.readTimeout = readTimeout
        self.writeTimeout = writeTimeout
        self.body = body
    }

    /// Enumerates every stored property: keep in sync when adding a field to RequestOptions.
    public static func +(lhs: RequestOptions, rhs: RequestOptions?) -> RequestOptions {
        guard let rhs else {
            return lhs
        }

        var finalHeaders: [String: String]? = lhs.headers
        var finalQueryParameters: [String: Any?]? = lhs.queryParameters
        var finalBody: [String: Any?]? = lhs.body
        var finalReadTimeout: TimeInterval? = lhs.readTimeout
        var finalWriteTimeout: TimeInterval? = lhs.writeTimeout

        if let rhsHeaders = rhs.headers {
            finalHeaders = (finalHeaders ?? [:]).merging(rhsHeaders) { _, new in new }
        }

        if let rhsQueryParameters = rhs.queryParameters {
            finalQueryParameters = (finalQueryParameters ?? [:]).merging(rhsQueryParameters) { _, new in new }
        }

        if let rhsBody = rhs.body {
            finalBody = rhsBody
        }

        if let rhsReadTimeout = rhs.readTimeout {
            finalReadTimeout = rhsReadTimeout
        }

        if let rhsWriteTimeout = rhs.writeTimeout {
            finalWriteTimeout = rhsWriteTimeout
        }

        return RequestOptions(
            headers: finalHeaders,
            queryParameters: finalQueryParameters,
            readTimeout: finalReadTimeout,
            writeTimeout: finalWriteTimeout,
            body: finalBody
        )
    }

    /// A copy carrying only the headers and query parameters. The helpers' rescue cleanup
    /// requests forward the caller's identification this way without inheriting the
    /// timeouts or explicit body meant for the primary requests.
    /// Enumerates the kept properties: revisit when adding a field to RequestOptions.
    public func withoutTimeoutsAndBody() -> RequestOptions {
        RequestOptions(headers: self.headers, queryParameters: self.queryParameters)
    }

    public func timeout(for callType: CallType) -> TimeInterval? {
        switch callType {
        case .read:
            self.readTimeout
        case .write:
            self.writeTimeout
        }
    }

    public func addHeaders(_ aHeaders: [String: String]) {
        self.headers?.merge(aHeaders) { _, new in new }
    }

    public func addHeader(name: String, value: String) -> Self {
        if !value.isEmpty {
            self.headers?[name] = value
        }
        return self
    }

    private(set) var headers: [String: String]?
    private(set) var queryParameters: [String: Any?]?
    private(set) var readTimeout: TimeInterval?
    private(set) var writeTimeout: TimeInterval?
    private(set) var body: [String: Any?]?
}
