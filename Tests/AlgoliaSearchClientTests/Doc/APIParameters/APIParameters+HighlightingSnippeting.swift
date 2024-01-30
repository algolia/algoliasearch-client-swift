//
//  APIParameters+HightlightingSnippeting.swift
//
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Highlighting/Snippeting

  func highlightingSnippeting() {
    func attributesToHighlight() {
      /*
              attributesToHighlight = [
                "attribute",
                "*" // returns all attributes in the index not just searchable attributes
              ]
             */

      func set_attributes_to_highlight() {
        let settings = Settings()
          .set(
            \.attributesToHighlight,
            to: [
              "author",
              "title",
              "content",
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func set_all_attributes_to_highlight() {
        let settings = Settings()
          .set(
            \.attributesToHighlight,
            to: [
              "*"
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func override_attributes_to_highlight() {
        let query = Query("query")
          .set(
            \.attributesToHighlight,
            to: [
              "title",
              "content",
            ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func attributesToSnippet() {
      /*
              attributesToSnippet: [
                .init(attribute: "attribute"),
                .init(attribute: "attribute2", count: number_of_words), // limits the size of the snippet
                ...
              ]
             */

      func set_attributes_to_snippet() {
        let settings = Settings()
          .set(
            \.attributesToSnippet,
            to: [
              .init(attribute: "content", count: 80),
              .init(attribute: "description"),
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func set_all_attributes_to_snippet() {
        let settings = Settings()
          .set(
            \.attributesToSnippet,
            to: [
              .init(attribute: "*", count: 80)
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func override_attributes_to_snippet() {
        let query = Query("query")
          .set(
            \.attributesToSnippet,
            to: [
              .init(attribute: "title"),
              .init(attribute: "content", count: 80),
            ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func highlightPreTag() {
      /*
              highlightPreTag: "opening_tag"
             */

      func set_default_highlight_pre_tag() {
        let settings = Settings()
          .set(\.highlightPreTag, to: "<em>")

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func override_default_highlight_pre_tag() {
        let query = Query("query")
          .set(\.highlightPreTag, to: "<strong>")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func highlightPostTag() {
      /*
              highlightPostTag: "closing_tag"
             */

      func set_default_highlight_post_tag() {
        let settings = Settings()
          .set(\.highlightPostTag, to: "</em>")

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func override_default_highlight_post_tag() {
        let query = Query("query")
          .set(\.highlightPostTag, to: "</strong>")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func snippetEllipsisText() {
      /*
              snippetEllipsisText: "text"
             */

      func set_default_snippet_ellipsis_text() {
        let settings = Settings()
          .set(\.snippetEllipsisText, to: "…")

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func override_default_snippet_ellipsis_text() {
        let query = Query("query")
          .set(\.snippetEllipsisText, to: "")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }

    func restrictHighlightAndSnippetArrays() {
      /*
              restrictHighlightAndSnippetArrays: true|false
             */

      func enable_restrict_highlight_and_snippet_arrays_by_default() {
        let settings = Settings()
          .set(\.restrictHighlightAndSnippetArrays, to: true)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }

      func enable_restrict_highlight_and_snippet_arrays() {
        let query = Query("query")
          .set(\.restrictHighlightAndSnippetArrays, to: false)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
