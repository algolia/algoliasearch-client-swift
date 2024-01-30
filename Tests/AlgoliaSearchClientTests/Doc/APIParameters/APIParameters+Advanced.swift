//
//  APIParameters+Advanced.swift
//
//
//  Created by Vladislav Fitc on 06/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Advanced

  func advanced() {
    func attributeForDistinct() {
      /*
             attributeForDistinct = "attribute"
             */
      func set_attributes_for_distinct() {
        let settings = Settings()
          .set(\.attributeForDistinct, to: "url")

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func distinct() {
      /*
             distinct = 0|1|2|3
             */
      func set_distinct() {
        let settings = Settings()
          .set(\.distinct, to: 0)
        // .set(\.distinct, to: 1)
        // .set(\.distinct, to: 2)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_distinct() {
        let query = Query("query")
          .set(\.distinct, to: 1)
        // .set(\.distinct, to: 0)
        // .set(\.distinct, to: 2)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func getRankingInfo() {
      /*
             getRankingInfo = true|false
             */
      func get_ranking_info() {
        let query = Query("query")
          .set(\.getRankingInfo, to: true)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func clickAnalytics() {
      /*
             clickAnalytics = true|false
             */
      func disable_click_analytics() {
        let query = Query("query")
          .set(\.clickAnalytics, to: false)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func enable_click_analytics() {
        let query = Query("query")
          .set(\.clickAnalytics, to: true)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func analytics() {
      /*
             analytics = true|false
             */
      func disable_analytics() {
        let query = Query("query")
          .set(\.analytics, to: false)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func enable_analytics_and_forward() {
        /// '94.228.178.246' should be replaced with the actual IP you would like
        /// Depending on your stack there are multiple ways to get this information.
        let configuration = SearchConfiguration(
          applicationID: "YourApplicationID",
          apiKey: "YourSearchOnlyAPIKey"
        )
        .set(\.defaultHeaders, to: ["X-Forwarded-For": "94.228.178.246"])
        let client = SearchClient(configuration: configuration)
        let index = client.index(withName: "index_name")

        let query = Query("query")
          .set(\.analytics, to: true)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func analyticsTags() {
      /*
             analyticsTags = [
               "tag value",
               ...
             ]
             */
      func add_analytics_tags() {
        let query = Query("query")
          .set(\.analyticsTags, to: ["front_end", "website2"])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func synonyms() {
      /*
             synonyms = true|false
             */
      func disable_synonyms() {
        let query = Query("query")
          .set(\.synonyms, to: false)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func replaceSynonymsInHighlight() {
      /*
             replaceSynonymsInHighlight = true|false
             */
      func set_replace_synonyms_in_highlights() {
        let settings = Settings()
          .set(\.replaceSynonymsInHighlight, to: false)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_replace_synonyms_in_highlights() {
        let query = Query("query")
          .set(\.replaceSynonymsInHighlight, to: true)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func minProximity() {
      /*
             minProximity = integer // from 1 to 7
             */
      func set_min_proximity() {
        let settings = Settings()
          .set(\.minProximity, to: 1)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_min_proximity() {
        let query = Query("query")
          .set(\.minProximity, to: 2)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func responseFields() {
      /*
             responseFields = [
               __ResponseField__,
               ...
             ]
             */
      func set_default_field() {
        let settings = Settings()
          .set(
            \.responseFields,
            to: [
              .hits,
              .hitsPerPage,
              .nbPages,
              .page,
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_default_field() {
        let query = Query("query")
          .set(\.responseFields, to: [.hits, .facets])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func maxFacetHits() {
      /*
             maxFacetHits = number_of_facet_hits
             */
      func set_max_facet_hits() {
        let settings = Settings()
          .set(\.maxFacetHits, to: 10)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_max_facet_hits() {
        let query = Query("query")
          .set(\.maxFacetHits, to: 5)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func percentileComputation() {
      /*
             percentileComputation = true|false
             */
      func override_percentile_computation() {
        let query = Query("query")
          .set(\.percentileComputation, to: false)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func attributeCriteriaComputedByMinProximity() {
      /*
             attributeCriteriaComputedByMinProximity = true|false
             */
      func set_attribute_criteria_computed_by_min_proximity() {
        let settings = Settings()
          .set(\.attributeCriteriaComputedByMinProximity, to: true)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func userData() {
      /*
             userData = __JSON__
             */
      func set_user_data() {
        let settings = Settings()
          .set(
            \.userData, to: ["extraData": "This is the custom data you want to store in your index"]
          )

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func enableABTest() {
      /*
             enableABTest = true|false
             */
      func set_ab_test() {
        let query = Query("query")
          .set(\.enableABTest, to: false)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
