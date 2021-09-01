//
//  RecommendationModel.swift
//  
//
//  Created by Vladislav Fitc on 01/09/2021.
//

import Foundation

public enum RecommendationModel: String, Codable {

  /// [Related Products](https://algolia.com/doc/guides/algolia-ai/recommend/#related-products)
  case relatedProducts = "related-products"

  /// [Frequently Bought Together](https://algolia.com/doc/guides/algolia-ai/recommend/#frequently-bought-together) products
  case boughtTogether = "bought-together"

}
