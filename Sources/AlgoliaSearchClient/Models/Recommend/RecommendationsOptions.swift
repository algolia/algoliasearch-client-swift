//
//  RecommendationsOptions.swift
//  
//
//  Created by Vladislav Fitc on 01/09/2021.
//

import Foundation

public struct RecommendationsOptions: Codable {

  /// Name of the index to target
  public let indexName: IndexName

  /// The recommendation model to use
  public let model: RecommendationModel

  /// The objectID to get recommendations for
  public let objectID: ObjectID

  /// The threshold to use when filtering recommendations by their score
  public let threshold: Int

  /// The maximum number of recommendations to retrieve
  public let maxRecommendations: Int?

  /// Search parameters to filter the recommendations
  public let queryParameters: Query?

  /// Search parameters to use as fallback when there are no recommendations
  public let fallbackParameters: Query?

  /**
   - parameter indexName: Name of the index to target
   - parameter model: The recommendation model to use
   - parameter objectID: The objectID to get recommendations for
   - parameter threshold: The threshold to use when filtering recommendations by their score
   - parameter maxRecommendations: The maximum number of recommendations to retrieve
   - parameter queryParameters: Search parameters to filter the recommendations
   - parameter fallbackParameters: Search parameters to use as fallback when there are no recommendations
   */
  public init(indexName: IndexName,
              model: RecommendationModel,
              objectID: ObjectID,
              threshold: Int = 0,
              maxRecommendations: Int? = nil,
              queryParameters: Query? = nil,
              fallbackParameters: Query? = nil) {
    self.indexName = indexName
    self.model = model
    self.objectID = objectID
    self.threshold = threshold
    self.maxRecommendations = maxRecommendations
    self.queryParameters = queryParameters
    self.fallbackParameters = fallbackParameters
  }

}

public struct FrequentlyBoughtTogetherOptions {

  internal let recommendationsOptions: RecommendationsOptions

  /**
   - parameter indexName: Name of the index to target
   - parameter objectID: The objectID to get recommendations for
   - parameter threshold: The threshold to use when filtering recommendations by their score
   - parameter maxRecommendations: The maximum number of recommendations to retrieve
   - parameter queryParameters: Search parameters to filter the recommendations
   */
  public init(indexName: IndexName,
              objectID: ObjectID,
              threshold: Int = 0,
              maxRecommendations: Int? = nil,
              queryParameters: Query? = nil) {
    recommendationsOptions = .init(indexName: indexName,
                                   model: .boughtTogether,
                                   objectID: objectID,
                                   threshold: threshold,
                                   maxRecommendations: maxRecommendations,
                                   queryParameters: queryParameters,
                                   fallbackParameters: nil)
  }

}

public struct RelatedProductsOptions {

  internal let recommendationsOptions: RecommendationsOptions

  /**
   - parameter indexName: Name of the index to target
   - parameter objectID: The objectID to get recommendations for
   - parameter threshold: The threshold to use when filtering recommendations by their score
   - parameter maxRecommendations: The maximum number of recommendations to retrieve
   - parameter queryParameters: Search parameters to filter the recommendations
   - parameter fallbackParameters: Search parameters to use as fallback when there are no recommendations
   */
  public init(indexName: IndexName,
              objectID: ObjectID,
              threshold: Int = 0,
              maxRecommendations: Int? = nil,
              queryParameters: Query? = nil,
              fallbackParameters: Query? = nil) {
    recommendationsOptions = .init(indexName: indexName,
                                   model: .relatedProducts,
                                   objectID: objectID,
                                   threshold: threshold,
                                   maxRecommendations: maxRecommendations,
                                   queryParameters: queryParameters,
                                   fallbackParameters: fallbackParameters)
  }

}
