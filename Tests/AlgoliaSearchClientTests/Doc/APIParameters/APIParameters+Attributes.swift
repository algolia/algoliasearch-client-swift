//
//  APIParameters+Attributes.swift
//
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Attributes

  func attributes() {
    func searchableAttributes() {
      /*
             searchableAttributes = [
               "attribute1",
               "attribute2, attribute3", // both attributes have the same priority
               .unordered("attribute4"),
             ]
             */
      func set_searchable_attributes() {
        let settings = Settings()
          .set(
            \.searchableAttributes,
            to: [
              "title,alternative_title",
              "author",
              .unordered("text"),
              "emails.personal",
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func attributesForFaceting() {
      /*
             attributesForFaceting = [
               "attribute1",
               .filterOnly("attribute2"),
               .searchable("attribute3")
             ]
             */
      func set_searchable_attributes() {
        let settings = Settings()
          .set(
            \.attributesForFaceting,
            to: [
              "author",
              .filterOnly("category"),
              .searchable("publisher"),
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func unretrievableAttributes() {
      /*
             unretrievableAttributes = [
               "attribute"
             ]
             */
      func unretrievable_attributes() {
        let settings = Settings()
          .set(
            \.unretrievableAttributes,
            to: [
              "total_number_of_sales"
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func attributesToRetrieve() {
      /*
             attributesToRetrieve = [
               "attribute1", // list of attributes to retrieve
               "attribute2"
             ]

             attributesToRetrieve = [
               "*" // retrieves all attributes
             ]

             attributesToRetrieve = [
               "*", // retrieves all attributes
               "-attribute1", // except this list of attributes (starting with a "-")
               "-attribute2"
             ]
             */
      func set_retrievable_attributes() {
        let settings = Settings()
          .set(
            \.attributesToRetrieve,
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
      func set_all_attributes_as_retrievable() {
        let settings = Settings()
          .set(\.attributesToRetrieve, to: ["*"])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func override_retrievable_attributes() {
        let query = Query("query")
          .set(
            \.attributesToRetrieve,
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
      func specify_attributes_not_to_retrieve() {
        let settings = Settings()
          .set(
            \.attributesToRetrieve,
            to: [
              "*",
              "-SKU",
              "-internal_desc",
            ])

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func restrictSearchableAttributes() {
      /*
             restrictSearchableAttributes = [
               "attribute"
             ]
             */
      func restrict_searchable_attributes() {
        let query = Query("query")
          .set(
            \.restrictSearchableAttributes,
            to: [
              "title",
              "author",
            ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
