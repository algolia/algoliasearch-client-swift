//
//  APIParameters+Languages.swift
//  
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import Foundation
import AlgoliaSearchClient

extension APIParameters {
  //MARK: - Languages
  func languages() {
    func ignorePlurals() {
      /*
       ignorePlurals = true|false|.queryLanguages(__[Language]__)
       */
      
      func set_languages_using_querylanguages() {
        let settings = Settings()
          .set(\.queryLanguages, to: [.spanish])
          .set(\.ignorePlurals, to: true)
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func set_querylanguages_override() {
        let query = Query("query")
          .set(\.ignorePlurals, to: [.spanish, .catalan])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    
    func removeStopWords() {
      /*
       removeStopWords = true|false|.queryLanguages(__[Language]__)
       */
      
      func set_languages_using_querylanguages() {
        let settings = Settings()
          .set(\.queryLanguages, to: [.spanish])
          .set(\.removeStopWords, to: true)
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func set_querylanguages_override() {
        let query = Query("query")
          .set(\.removeStopWords, to: ["catalan", "spanish"])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func camelCaseAttributes() {
      /*
       camelCaseAttributes = [
         "attribute",
         ...
       ]
       */
      
      func set_camel_case_attributes() {
        let settings = Settings()
          .set(\.camelCaseAttributes, to: ["description"])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func decompoundedAttributes() {
      /*
       decompoundedAttributes = [
         language: ["attribute", "attribute"],
         language: ["attribute"],
         ...
       ]
       */
      
      func set_decompounded_attributes() {
        let settings = Settings()
          .set(\.decompoundedAttributes, to: [.german: ["name"]])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func set_decompounded_multiple_attributes() {
        let settings = Settings()
          .set(\.decompoundedAttributes, to: [
            .german: ["description_de", "name_de"],
            .finnish: ["name_fi", "description_fi"]
          ])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
    }
    func keepDiacriticsOnCharacters() {
      /*
       keepDiacriticsOnCharacters = "øé"
       */
      
      func set_keep_diacritics_on_characters() {
        let settings = Settings()
          .set(\.keepDiacriticsOnCharacters, to: "øé")
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func customNormalization() {
      /*
       customNormalization: [String: [String: String]] = [
         "default": [
           "ä": "ae",
           "ü": "ue"
         ]
       ]
       */
      func set_custom_normalization() {
        let settings = Settings()
          .set(\.customNormalization, to: [
            "default": [
              "ä": "ae",
              "ü": "ue"
            ]
          ])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func queryLanguages() {
      /*
       queryLanguages = [__Language__, ...]
       */
      func set_languages_using_querylanguages() {
        let settings = Settings()
          .set(\.queryLanguages, to: [.spanish])
          .set(\.ignorePlurals, to: true)
          .set(\.removeStopWords, to: true)
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func set_querylanguages_override() {
        let query = Query("query")
          .set(\.queryLanguages, to: [.catalan, .spanish])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func set_querylanguages_with_japanese_query() {
        let query = Query("query")
          .set(\.queryLanguages, to: [.japanese, .english])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
    }
    func indexLanguages() {
      /*
       indexLanguages = [__Language__, ...]
       */
      func set_indexlanguages() {
        let settings = Settings()
          .set(\.indexLanguages, to: [.japanese])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func naturalLanguages() {
      /*
       naturalLanguages = [__Language__, ...]
       */
      
      func set_natural_languages() {
        let query = Query("query")
          .set(\.naturalLanguages, to: [.french])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func override_natural_languages_with_query() {
        let query = Query("query")
          .set(\.naturalLanguages, to: [.french])
          .set(\.removeWordsIfNoResults, to: .firstWords)
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
