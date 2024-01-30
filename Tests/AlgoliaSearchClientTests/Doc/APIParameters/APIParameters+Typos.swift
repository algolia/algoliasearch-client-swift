//
//  APIParameters+Typos.swift
//
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Typos

  func typos() {
    func minWordSizefor1Typo() {
      /*
             minWordSizefor1Typo = min_word_size
             */
      func set_default_min_word_size_for_one_typo() {
        let settings = Settings()
          .set(\.minWordSizeFor1Typo, to: 4)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func override_default_min_word_size_for_one_typo() {
        let query = Query("query")
          .set(\.minWordSizeFor1Typo, to: 2)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func minWordSizefor2Typos() {
      /*
             minWordSizefor2Typos = min_word_size
             */

      func set_default_min_word_size_for_two_typos() {
        let settings = Settings()
          .set(\.minWordSizeFor2Typos, to: 4)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func override_default_min_word_size_for_two_typos() {
        let query = Query("query")
          .set(\.minWordSizeFor2Typos, to: 2)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func typoTolerance() {
      /*
             typoTolerance = .#{true}|.#{false}|.#{min}|.#{strict}
             */

      func set_default_typo_tolerance_mode() {
        let settings = Settings()
          .set(\.typoTolerance, to: true)
        // .set(\.typoTolerance, to: false)
        // .set(\.typoTolerance, to: .min)
        // .set(\.typoTolerance, to: .strict)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func override_default_typo_tolerance_mode() {
        let query = Query("query")
          .set(\.typoTolerance, to: false)
        // .set(\.typoTolerance, to: true)
        // .set(\.typoTolerance, to: .min)
        // .set(\.typoTolerance, to: .strict)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func allowTyposOnNumericTokens() {
      /*
             allowTyposOnNumericTokens = true|false
             */

      func disable_typos_on_numeric_tokens_by_default() {
        let settings = Settings()
          .set(\.allowTyposOnNumericTokens, to: false)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func disable_typos_on_numeric_tokens_at_search_time() {
        let query = Query("query")
          .set(\.allowTyposOnNumericTokens, to: false)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func disableTypoToleranceOnAttributes() {
      /*
             disableTypoToleranceOnAttributes = [
             "attribute",
             ...
             ]
             */

      func disabling_typo_tolerance_for_some_attributes_by_default() {
        let settings = Settings()
          .set(\.disableTypoToleranceOnAttributes, to: ["sku"])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func disabling_typo_tolerance_for_some_attributes_search_time() {
        let query = Query("query")
          .set(\.disableTypoToleranceOnAttributes, to: ["sku"])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func disableTypoToleranceOnWords() {
      /*
             disableTypoToleranceOnWords = [
             "word",
             ...
             ]
             */

      func disable_typo_tolerance_for_words() {
        let settings = Settings()
          .set(
            \.disableTypoToleranceOnWords,
            to: [
              "wheel",
              "1X2BCD",
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func separatorsToIndex() {
      /*
             separatorsToIndex = "separators"
             */

      let settings = Settings()
        .set(\.separatorsToIndex, to: "+#")

      index.setSettings(settings) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
  }
}
