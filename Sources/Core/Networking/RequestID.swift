//
//  RequestID.swift
//
//
//  Created by Algolia on 10/08/2026.
//

import Foundation

/// Mints the Request-ID tracing header sent by the clients that support it.
public enum RequestID {
    /// The name of the header carrying the Request-ID.
    public static let httpHeaderField = "Request-ID"

    /// The name of the query parameter carrying the Request-ID, the fallback channel the
    /// server consults when the header is absent.
    public static let queryParameterName = "x-algolia-request-id"

    private static let alphabet: [Character] = Array(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    )

    /// Returns a fresh 11-character base62 identifier suitable for the Request-ID header.
    public static func generate() -> String {
        String((0 ..< 11).compactMap { _ in self.alphabet.randomElement() })
    }

    /// Whether the given headers already carry a Request-ID entry, whatever its casing.
    /// Header dictionaries keep the caller's literal casing, so the lookup must not assume
    /// a canonical form.
    public static func hasRequestID(in headers: [String: String]?) -> Bool {
        guard let headers else {
            return false
        }

        return headers.keys.contains { $0.caseInsensitiveCompare(self.httpHeaderField) == .orderedSame }
    }

    /// Whether the given query parameters already carry an `x-algolia-request-id` entry,
    /// whatever its casing. The server consults the query parameter only when the header
    /// is absent, so a caller supplying the ID on that channel must suppress the header.
    public static func hasRequestIDQueryParameter(in queryParameters: [String: Any?]?) -> Bool {
        guard let queryParameters else {
            return false
        }

        return queryParameters.keys.contains {
            $0.caseInsensitiveCompare(self.queryParameterName) == .orderedSame
        }
    }

    /// Derives the request options carrying the Request-ID shared by every request of one
    /// helper invocation. Returns the options untouched when the configuration does not
    /// support Request-ID or the caller already supplied one through the options headers,
    /// the default headers, or the options query parameters, which also makes nested
    /// helpers reuse the ID minted by their caller.
    public static func withRequestID(
        _ requestOptions: RequestOptions?,
        configuration: BaseConfiguration
    ) -> RequestOptions? {
        guard configuration.requestIDEnabled,
              !self.hasRequestID(in: requestOptions?.headers),
              !self.hasRequestID(in: configuration.defaultHeaders),
              !self.hasRequestIDQueryParameter(in: requestOptions?.queryParameters)
        else {
            return requestOptions
        }

        return RequestOptions(headers: [self.httpHeaderField: self.generate()]) + requestOptions
    }
}
