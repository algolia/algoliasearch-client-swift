//
//  APIParameters.swift
//  
//
//  Created by Vladislav Fitc on 06/07/2020.
//

import Foundation
import AlgoliaSearchClient

struct APIParameters: SnippetsCollection {
  
  func searchQuery() {
    /*
     index.search(query: "my query")
     */
    
    func searchAQuery() {
      index.search(query: "my query") { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
    
    func searchEverything() {
      index.search(query: "") { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
    
  }
  
  func similarQuery() {
    /*
     similarQuery: String = "query"
     */
    
    let query = Query()
      .set(\.similarQuery, to: "Comedy Drama Crime McDormand Macy Buscemi Stormare Presnell Coen")
      .set(\.filters, to: "year:1991 TO 2001")
    
    index.search(query: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }

  }
  
  func attributes() {
    
    //MARK: - searchableAttributes
    
    func setSearchableAttributes() {
      /*
      searchableAttributes = [
        "attribute1",
        "attribute2, attribute3", // both attributes have the same priority
        .unordered("attribute4"),
      ]
      */
      
      index.setSettings(Settings()
        .set(\.searchableAttributes, to: [
          "title,alternative_title",
          "author",
          .unordered("text"),
          "emails.personal"
        ])
      ) { result in }
    }
    
    //MARK: - attributesForFaceting
    
    /*
    attributesForFaceting = [
      "attribute1",
      .filterOnly("attribute2"),
      .searchable("attribute3")
    ]
    */
    
    func attributesForFaceting() {
      index.setSettings(Settings()
        .set(\.attributesForFaceting, to: [
          "author",
          .filterOnly("category"),
          .searchable("publisher")
        ])
      ) { result in }
    }

    //MARK: - unretrievableAttributes
    
    func unretrievableAttributes() {
      /*
      unretrievableAttributes = [
        "attribute"
      ]
      */
      
      index.setSettings(Settings()
        .set(\.unretrievableAttributes, to: [
          "total_number_of_sales"
        ])
      ) { result in }
    }
    
    //MARK: - attributesToRetrieve
    
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
    
    func setRetrievableAttributes() {
      index.setSettings(Settings()
        .set(\.attributesToRetrieve, to: [
          "author",
          "title",
          "content"
        ])
      ) { result in }
    }
    
    func setAllAttributesAsRetrievable() {
      index.setSettings(Settings()
        .set(\.attributesToRetrieve, to: [
          "*"
        ])
      ) { result in }
    }
    
    func overrideRetrievableAttributes() {
      let query = Query("query")
        .set(\.attributesToRetrieve, to: [
          "title",
          "content"
        ])

      index.search(query: query) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
    
    func specifyAttributesNotToRetrieve() {
      index.setSettings(Settings()
        .set(\.attributesToRetrieve, to: [
          "*",
          "-SKU",
          "-internal_desc"
        ])
      ) { result in }
    }
    
    //MARK: - restrictSearchableAttributes
        
    var query = Query("query")
      .set(\.restrictSearchableAttributes, to: [
        "title",
        "author"
      ])

    index.search(query: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
    
    query.restrictSearchableAttributes = [
      "attribute"
    ]
      
  }
  
  func ranking() {
    
    //MARK: - ranking
    
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
    
    func setDefaultRanking() {
      index.setSettings(Settings()
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
      ){ result in }
    }
    
    func setRankingByAttributeAsc() {
      index.setSettings(Settings()
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
      ) { result in }
    }
    
    func setRankingByAttributeDesc() {
      index.setSettings(Settings()
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
      ) { result in }

    }
    
    //MARK: - customRanking
    /*
     customRanking = [
       #{.asc}("attribute1"),
       #{.desc}("attribute2")
     ]
     */

    func customRanking() {
      index.setSettings(Settings()
        .set(\.customRanking, to: [
          .desc("popularity"),
          .asc("price")
        ])
      ) { result in }
    }
    
    //MARK: - replicas
    /*
     replicas = [
       "replica_index1",
       "replica_index2"
     ]
     */
    
    func replicas() {
      index.setSettings(Settings()
        .set(\.replicas, to: [
          "name_of_replica_index1",
          "name_of_replica_index2"
        ])
      ) { result in }
    }
    
  }
  
  //MARK: - Filtering
  
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
          .set(\.filters, to: "available = 1 AND (category:Book OR NOT category:Ebook) AND _tags:published AND publication_date:1441745506 TO 1441755506 AND inStock > 0 AND author:\"John Doe\"")
        
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
      
      func set_single_string_value() {
        let query = Query("query")
          .set(\.facetFilters, to: [
            "category:Book"
          ]
        )
        

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func set_multiple_string_values() {
        let query = Query("query")
          .set(\.facetFilters, to: [
            "category:Book", "author:John Doe"
          ]
        )

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func set_multiple_values_within_array() {
                
        let query = Query("query")
          .set(\.facetFilters, to: [
            .or("category:Book", "category:Movie")
          ]
        )

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func combine_arrays_and_strings() {
        let query = Query("query")
          .set(\.facetFilters, to: [
            .or("category:Book", "category:Movie"), "author:John Doe"
          ]
        )

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
    }
    
    func optionalFilters() {
      
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
      func applyNumericFilters() {
        let query = Query("query")
          .set(\.numericFilters, to: [
            .or(
              "inStock = 1",
              "deliveryDate < 1441755506"
            ),
            "price < 1000"
          ])

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    
    func tagFilters() {
      func applyTagFilters() {
        let query = Query("query").set(\.tagFilters, to: [
          .or(
            "Book",
            "Movie"
          ),
          "SciFi"
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
