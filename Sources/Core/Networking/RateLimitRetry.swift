//
//  RateLimitRetry.swift
//

import Foundation

/// Shared 429 Retry-After wait helpers used by the transporter and generated
/// client configurations.
public enum RateLimitRetry {
    static let defaultWaitNanoseconds: UInt64 = 1_000_000_000
    /// Longest wait handed to `Task.sleep`. Staying within `Int64` keeps the value
    /// positive on runtimes that convert the delay to a signed nanosecond count.
    static let maxWaitNanoseconds = UInt64(Int64.max)
    public static let defaultMaxRetries = 3

    /// `Retry-After` as a wait in nanoseconds.
    /// Only a positive whole-number-of-seconds string is honored; anything else
    /// (missing, `0`, HTTP-date, junk) waits 1s. Values too large for the sleep
    /// primitive wait `maxWaitNanoseconds`.
    static func waitNanoseconds(from headers: [String: String]?) -> UInt64 {
        let raw = headers?.first {
            $0.key.caseInsensitiveCompare("Retry-After") == .orderedSame
        }?.value.trimmingCharacters(in: .whitespacesAndNewlines)

        // ASCII digits only: a Character comparison would let a digit carrying a combining mark
        // through the guard and into the saturating branch below
        guard let raw, !raw.isEmpty, raw.unicodeScalars.allSatisfy({ (48 ... 57).contains($0.value) }) else {
            return self.defaultWaitNanoseconds
        }

        guard let seconds = UInt64(raw) else {
            return self.maxWaitNanoseconds
        }

        guard seconds > 0 else {
            return self.defaultWaitNanoseconds
        }

        let (nanos, overflow) = seconds.multipliedReportingOverflow(by: 1_000_000_000)
        return overflow ? self.maxWaitNanoseconds : min(nanos, self.maxWaitNanoseconds)
    }

    /// The `HTTPError` carried by an `AlgoliaError.httpError`, or nil for any other error.
    static func httpError(from error: Error) -> HTTPError? {
        guard case let .httpError(httpError) as AlgoliaError = error else {
            return nil
        }

        return httpError
    }

    static func isRateLimited(_ httpError: HTTPError) -> Bool {
        httpError.statusCode == HTTPStatusСode.tooManyRequests
    }

    static func isRateLimited(_ error: Error) -> Bool {
        guard let httpError = self.httpError(from: error) else {
            return false
        }

        return self.isRateLimited(httpError)
    }
}
