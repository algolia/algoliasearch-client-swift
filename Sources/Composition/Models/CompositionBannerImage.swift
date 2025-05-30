// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

/// Image to show inside a banner.
public struct CompositionBannerImage: Codable, JSONEncodable {
    public var urls: [CompositionBannerImageUrl]?
    public var title: String?

    public init(urls: [CompositionBannerImageUrl]? = nil, title: String? = nil) {
        self.urls = urls
        self.title = title
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case urls
        case title
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.urls, forKey: .urls)
        try container.encodeIfPresent(self.title, forKey: .title)
    }
}

extension CompositionBannerImage: Equatable {
    public static func ==(lhs: CompositionBannerImage, rhs: CompositionBannerImage) -> Bool {
        lhs.urls == rhs.urls &&
            lhs.title == rhs.title
    }
}

extension CompositionBannerImage: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.urls?.hashValue)
        hasher.combine(self.title?.hashValue)
    }
}
