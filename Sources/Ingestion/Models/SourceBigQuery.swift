// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation

#if canImport(AnyCodable)
  import AnyCodable
#endif

public struct SourceBigQuery: Codable, JSONEncodable, Hashable {

  /** Project ID of the BigQuery Source. */
  public var projectID: String
  /** Dataset ID of the BigQuery Source. */
  public var datasetID: String
  public var dataType: BigQueryDataType?
  /** Table name (for default BQ). */
  public var table: String?
  /** Table prefix (for Google Analytics). */
  public var tablePrefix: String?
  /** Custom SQL request to extract data from the BigQuery table. */
  public var customSQLRequest: String?
  /** The name of the column that contains the unique ID, used as `objectID` in Algolia. */
  public var uniqueIDColumn: String?

  public init(
    projectID: String, datasetID: String, dataType: BigQueryDataType? = nil, table: String? = nil,
    tablePrefix: String? = nil, customSQLRequest: String? = nil, uniqueIDColumn: String? = nil
  ) {
    self.projectID = projectID
    self.datasetID = datasetID
    self.dataType = dataType
    self.table = table
    self.tablePrefix = tablePrefix
    self.customSQLRequest = customSQLRequest
    self.uniqueIDColumn = uniqueIDColumn
  }

  public enum CodingKeys: String, CodingKey, CaseIterable {
    case projectID
    case datasetID
    case dataType
    case table
    case tablePrefix
    case customSQLRequest
    case uniqueIDColumn
  }

  // Encodable protocol methods

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(projectID, forKey: .projectID)
    try container.encode(datasetID, forKey: .datasetID)
    try container.encodeIfPresent(dataType, forKey: .dataType)
    try container.encodeIfPresent(table, forKey: .table)
    try container.encodeIfPresent(tablePrefix, forKey: .tablePrefix)
    try container.encodeIfPresent(customSQLRequest, forKey: .customSQLRequest)
    try container.encodeIfPresent(uniqueIDColumn, forKey: .uniqueIDColumn)
  }
}