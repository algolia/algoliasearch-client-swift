//
//  TransformationOptions.swift
//
//  Configuration for the ingestion transporter used by the `*WithTransformation` helpers on
//  SearchClient. `region` is required; every other field is an optional override — an unset
//  field keeps the Ingestion API default (25 s timeouts, region-derived hosts, no compression).
//  Credentials are always taken from the parent SearchClient.
//
//  To make another `IngestionClient` (configuration) property configurable from the search
//  client's `*WithTransformation` helpers, add it here as an optional override and forward it
//  in `SearchClient.resolvedIngestionClient()`.
//
//  See https://www.algolia.com/doc/libraries/sdk/methods/ingestion

#if canImport(AlgoliaCore)
    import AlgoliaCore
#endif
import Foundation

public struct TransformationOptions {
    /// The Algolia region for the Ingestion API. Required.
    public let region: Region

    /// Override the read timeout.
    public var readTimeout: TimeInterval?

    /// Override the write timeout.
    public var writeTimeout: TimeInterval?

    /// Override the hosts.
    public var hosts: [RetryableHost]?

    /// Override the compression.
    public var compression: CompressionAlgorithm?

    /// Additional headers merged into every request.
    public var defaultHeaders: [String: String]?

    /// - parameter region: The Algolia region for the Ingestion API (`Region.us` or `Region.eu`). Required.
    /// - parameter readTimeout: Override the read timeout.
    /// - parameter writeTimeout: Override the write timeout.
    /// - parameter hosts: Override the hosts.
    /// - parameter compression: Override the compression.
    /// - parameter defaultHeaders: Additional headers merged into every request.
    public init(
        region: Region,
        readTimeout: TimeInterval? = nil,
        writeTimeout: TimeInterval? = nil,
        hosts: [RetryableHost]? = nil,
        compression: CompressionAlgorithm? = nil,
        defaultHeaders: [String: String]? = nil
    ) {
        self.region = region
        self.readTimeout = readTimeout
        self.writeTimeout = writeTimeout
        self.hosts = hosts
        self.compression = compression
        self.defaultHeaders = defaultHeaders
    }
}
