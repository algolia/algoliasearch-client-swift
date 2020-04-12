//
//  Command+Places.swift
//  
//
//  Created by Vladislav Fitc on 10/04/2020.
//

import Foundation

extension Command {

  enum Places {
    
    struct Search: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(query: PlacesQuery, requestOptions: RequestOptions?) {
        self.urlRequest = .init(method: .post, path: .places >>> PlacesCompletion.query, body: query.httpBody, requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }
      
    }
    
    struct GetObject: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(objectID: ObjectID, requestOptions: RequestOptions?) {
        self.urlRequest = .init(method: .get, path: .places >>> PlacesCompletion.objectID(objectID), requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }
      
    }
    
    struct ReverseGeocoding: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(geolocation: Point, language: Language, hitsPerPage: Int?, requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate([
          .aroundLatLng: "\(geolocation.latitude),\(geolocation.longitude)",
          .hitsPerPage: hitsPerPage.flatMap(String.init),
          .language: language.rawValue
        ])
        self.urlRequest = .init(method: .get, path: .places >>> PlacesCompletion.reverse, requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }
      
    }
    
  }

}
