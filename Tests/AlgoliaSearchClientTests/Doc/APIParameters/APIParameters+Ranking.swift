//
//  APIParameters+Ranking.swift
//  
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import Foundation
import AlgoliaSearchClient

extension APIParameters {
  //MARK: - Ranking
  func ranking() {
    func ranking() {
      /*
       ranking = [
         // the `asc` and `desc` modifiers must be placed at the top
         // if you are configuring an index for sorting purposes only
         .#{asc}("attribute1"),
         .#{desc}("attribute2"),
         .#{typo},
         .#{geo},
         .#{words},
         .#{filters},
         .#{proximity},
         .#{attribute},
         .#{exact},
         .#{custom}
       ]
       */
      func set_default_ranking() {
        let settings = Settings()
          .set(\.ranking, to: [
            .typo,
            .geo,
            .words,
            .filters,
            .proximity,
            .attribute,
            .exact,
            .custom
          ])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func set_ranking_by_attribute_asc() {
        let settings = Settings()
          .set(\.ranking, to: [
            .asc("price"),
            .typo,
            .geo,
            .words,
            .filters,
            .proximity,
            .attribute,
            .exact,
            .custom
          ])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func set_ranking_by_attribute_desc() {
        let settings = Settings()
          .set(\.ranking, to: [
            .desc("price"),
            .typo,
            .geo,
            .words,
            .filters,
            .proximity,
            .attribute,
            .exact,
            .custom
          ])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func customRanking() {
      /*
       customRanking = [
         #{.asc}("attribute1"),
         #{.desc}("attribute2")
       ]
       */
      func restrict_searchable_attributes() {
        let settings = Settings()
          .set(\.customRanking, to: [
            .desc("popularity"),
            .asc("price")
          ])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func replicas() {
      /*
       replicas = [
         "replica_index1",
         "replica_index2"
       ]
       */
      func set_replicas() {
        let settings = Settings()
          .set(\.replicas, to: [
            "name_of_replica_index1",
            "name_of_replica_index2"
          ])
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
