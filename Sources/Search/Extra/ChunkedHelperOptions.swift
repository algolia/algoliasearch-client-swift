//
//  ChunkedHelperOptions.swift
//
//
//  Created by Algolia on 25/05/2026.
//

/// Options shared by the chunked helpers (`chunkedBatch`, `saveObjects`,
/// `deleteObjects`, `partialUpdateObjects`, `replaceAllObjects`, and the
/// `WithTransformation` helpers).
public struct ChunkedHelperOptions {
    /// Default maximum number of retries used by every chunked helper and the
    /// `waitFor*` family when the caller does not provide a value.
    public static let defaultMaxRetries = 100

    /// Default maximum number of retries used by `replaceAllObjects` when the
    /// caller does not provide a value.
    public static let defaultReplaceAllObjectsMaxRetries = 800

    /// Maximum number of retries forwarded to every nested `waitForTask`
    /// call performed by the chunked helpers. Defaults to ``defaultMaxRetries``.
    public let maxRetries: Int

    public init(maxRetries: Int = ChunkedHelperOptions.defaultMaxRetries) {
        self.maxRetries = maxRetries
    }
}
