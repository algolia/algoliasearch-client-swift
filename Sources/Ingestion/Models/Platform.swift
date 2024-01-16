// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation

#if canImport(AnyCodable)
  import AnyCodable
#endif

/// Describe which platform the Authentication is used for.
public enum Platform: String, Codable, CaseIterable {
  case bigcommerce = "bigcommerce"
  case commercetools = "commercetools"
}