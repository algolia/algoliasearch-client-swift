//
//  APIParameter+QueryStrategy.swift
//
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Query Strategy

  func queryStrategy() {
    func queryType() {
      /*
             queryType = .#{prefixLast}|.#{prefixAll}|.#{prefixNone}
             */
      func set_default_query_type() {
        let settings = Settings()
          .set(\.queryType, to: .prefixLast)
        // .set(\.queryType, to: .prefixAll)
        // .set(\.queryType, to: .prefixNone)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_default_query_type() {
        let query = Query("query")
          .set(\.queryType, to: .prefixAll)
        // .set(\.queryType, to: .prefixLast)
        // .set(\.queryType, to: .prefixNone)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func removeWordsIfNoResults() {
      /*
             removeWordsIfNoResults = .#{none}|.#{lastWords}|.#{firstWords}|.#{allOptional}
             */
      func set_default_remove_words_if_no_result() {
        let settings = Settings()
          .set(\.removeWordsIfNoResults, to: RemoveWordIfNoResults.none)
        // .set(\.removeWordsIfNoResults, to: .lastWords)
        // .set(\.removeWordsIfNoResults, to: .firstWords)
        // .set(\.removeWordsIfNoResults, to: .allOptional)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_default_remove_words_if_no_results() {
        let query = Query("query")
          .set(\.removeWordsIfNoResults, to: .lastWords)
        // .set(\.removeWordsIfNoResults, to: .none)
        // .set(\.removeWordsIfNoResults, to: .firstWords)
        // .set(\.removeWordsIfNoResults, to: .allOptional)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func advancedSyntax() {
      /*
             advancedSyntax = true|false
             */
      func enable_advanced_syntax_by_default() {
        let settings = Settings()
          .set(\.advancedSyntax, to: true)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func enable_advanced_syntax_search_time() {
        let query = Query("query")
          .set(\.advancedSyntax, to: true)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func optionalWords() {
      /*
             optionalWords = [
               "word",
               "word1 word2", // both words are optional
               ...
             ]
             */
      func set_default_optional_words() {
        let settings = Settings()
          .set(\.optionalWords, to: ["word1", "word2 word3"])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func overide_default_optional_words() {
        let query = Query("query")
          .set(\.optionalWords, to: ["word1", "word2 word3"])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func or_between_words() {
        let queryString = "query"
        let query = Query(queryString)
          .set(\.optionalWords, to: [queryString])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func disablePrefixOnAttributes() {
      /*
             disablePrefixOnAttributes = [
               "attribute",
               ...
             ]
             */
      func disabling_prefix_search_for_some_attributes_by_default() {
        let settings = Settings()
          .set(\.disablePrefixOnAttributes, to: ["sku"])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func disableExactOnAttributes() {
      /*
             disableExactOnAttributes = [
               "attribute",
               ...
             ]
             */
      func disabling_exact_for_some_attributes_by_default() {
        let settings = Settings()
          .set(\.disableExactOnAttributes, to: ["keywords"])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func disabling_exact_for_some_attributes_search_time() {
        let query = Query("query")
          .set(\.disableExactOnAttributes, to: ["keywords"])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func exactOnSingleWordQuery() {
      /*
             exactOnSingleWordQuery = .#{attribute}|.#{none}|.#{word}
             */
      func set_default_exact_single_word_query() {
        let settings = Settings()
          .set(\.exactOnSingleWordQuery, to: .attribute)
        // .set(\.exactOnSingleWordQuery, to: ExactOnSingleWordQuery.none)
        // .set(\.exactOnSingleWordQuery, to: .word)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_default_exact_single_word_query() {
        let query = Query("query")
          .set(\.exactOnSingleWordQuery, to: ExactOnSingleWordQuery.none)
        // .set(\.exactOnSingleWordQuery, to: .attribute)
        // .set(\.exactOnSingleWordQuery, to: .word)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func alternativesAsExact() {
      /*
             alternativesAsExact = [
               .#{ignorePlurals},
               .#{singleWordSynonym},
               .#{multiWordsSynonym}
             ]
             */
      func set_default_aternative_as_exact() {
        let settings = Settings()
          .set(\.alternativesAsExact, to: [.ignorePlurals, .singleWordSynonym])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_default_aternative_as_exact() {
        let query = Query("query")
          .set(\.alternativesAsExact, to: [.multiWordsSynonym])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func advancedSyntaxFeatures() {
      /*
             advancedSyntaxFeatures = [
               .#{exactPhrase},
               .#{excludeWords}
             ]
             */
      func enable_advanced_syntax_by_default() {
        let settings = Settings()
          .set(\.advancedSyntax, to: true)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func enable_advanced_syntax_exact_phrase() {
        let settings = Settings()
          .set(\.advancedSyntax, to: true)
          .set(\.advancedSyntaxFeatures, to: [.exactPhrase])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func enable_advanced_syntax_exclude_words() {
        let query = Query("query")
          .set(\.advancedSyntax, to: true)
          .set(\.advancedSyntaxFeatures, to: [.excludeWords])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
