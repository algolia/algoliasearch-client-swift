//
//  APIParameters+Filtering.swift
//
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Filtering

  func filtering() {
    func filters() {
      /*
             query.filters = "attribute:value [AND | OR | NOT](#boolean-operators) attribute:value"
                             "numeric_attribute [= | != | > | >= | < | <=](#numeric-comparisons) numeric_value"
                             "attribute:lower_value [TO](#numeric-range) higher_value"
                             "[facetName:facetValue](#facet-filters)"
                             "[_tags](#tag-filters):value"
                             "attribute:value"
             */

      func applyFilters() {
        let query = Query("query")
          .set(\.filters, to: "(category:Book OR category:Ebook) AND _tags:published")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func applyAllFilters() {
        let query = Query("query")
          .set(
            \.filters,
            to:
              "available = 1 AND (category:Book OR NOT category:Ebook) AND _tags:published AND publication_date:1441745506 TO 1441755506 AND inStock > 0 AND author:\"John Doe\""
          )

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func escapeSpaces() {
        let query = Query("query")
          .set(\.filters, to: "category:'Books and Comics'")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func escapeKeywords() {
        let query = Query("query")
          .set(\.filters, to: "keyword:'OR'")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func escapeSingleQuotes() {
        let query = Query("query")
          .set(\.filters, to: "content:'It\\'s a wonderful day'")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func escapeDoubleQuotes() {
        let query = Query("query")
          .set(\.filters, to: "content:'She said \"Hello World\"'")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func facetFilters() {
      /*
              query.facetFilters = [
                "attribute:value", // (single string)

                // attribute1:value AND attribute2:value (multiple strings)
                "attribute1:value", "attribute2:value"

                // attribute1:value OR attribute2:value (multiple strings within an array)
                .or("attribute1:value", "attribute2:value"),

                // (attribute1:value OR attribute2:value) AND attribute3:value (combined strings and arrays)
                .or("attribute1:value", "attribute2:value"), "attribute3:value",

                ...
              ]
             */

      func set_single_string_value() {
        let query = Query("query")
          .set(
            \.facetFilters,
            to: [
              "category:Book"
            ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func set_multiple_string_values() {
        let query = Query("query")
          .set(
            \.facetFilters,
            to: [
              "category:Book", "author:John Doe",
            ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func set_multiple_values_within_array() {
        let query = Query("query")
          .set(
            \.facetFilters,
            to: [
              .or("category:Book", "category:Movie")
            ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func combine_arrays_and_strings() {
        let query = Query("query")
          .set(
            \.facetFilters,
            to: [
              .or("category:Book", "category:Movie"), "author:John Doe",
            ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func optionalFilters() {
      /*
              optionalFilters = [
                "attribute:value",
                .or("attribute1:value", "attribute2:value")
              ]
             */

      func applyFilters() {
        let query = Query()
          .set(\.optionalFilters, to: ["category:Book", "author:John Doe"])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func applyNegativeFilters() {
        let query = Query()
          .set(\.optionalFilters, to: ["category:Book", "author:-John Doe"])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func numericFilters() {
      /*
             numericFilters = [
               "numeric_attribute [= | != | > | >= | < | <=](#numeric-comparisons) numeric_value",
               "attribute:lower_value [TO](#numeric-range) higher_value"
             ]
             */

      func applyNumericFilters() {
        let query = Query("query")
          .set(
            \.numericFilters,
            to: [
              .or("inStock = 1", "deliveryDate < 1441755506"),
              "price < 1000",
            ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func tagFilters() {
      /*
             tagFilters = [
               "value",

               // value1 OR value2
               .or("value1", "value2"),

               // (value1 OR value2) AND value3
               .or("value1", "value2"), "value3",

               ...
             ]
             */

      func applyTagFilters() {
        let query = Query("query").set(
          \.tagFilters,
          to: [
            .or("Book", "Movie"),
            "SciFi",
          ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func sumOrFiltersScore() {
      /*
             sumOrFiltersScores = true|false
             */

      let query = Query("query")
        .set(\.sumOrFiltersScores, to: true)

      index.search(query: query) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
  }
}
