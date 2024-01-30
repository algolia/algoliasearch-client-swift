//
//  APIParameters+Performance.swift
//
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Performance

  func performance() {
    func numericAttributesForFiltering() {
      /*
              numericAttributesForFiltering = [
                "attribute1",
                .#{equalOnly}("attribute2")
              ]
             */
      func set_numeric_attributes_for_filtering() {
        let settings = Settings()
          .set(\.numericAttributesForFiltering, to: ["quantity", "popularity"])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func allowCompressionOfIntegerArray() {
      /*
              allowCompressionOfIntegerArray = true|false
             */
      func enable_compression_of_integer_array() {
        let settings = Settings()
          .set(\.allowCompressionOfIntegerArray, to: true)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
