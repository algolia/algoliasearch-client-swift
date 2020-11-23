//
//  Command+Places.swift
//  
//
//  Created by Vladislav Fitc on 10/04/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Places {

    struct Search: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(query: PlacesQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .post, path: .places >>> PlacesCompletion.query, body: query.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct GetObject: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .get, path: .places >>> PlacesCompletion.objectID(objectID), requestOptions: self.requestOptions)
      }

    }

    struct ReverseGeocoding: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(geolocation: Point, language: Language?, hitsPerPage: Int?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions.updateOrCreate([
          .aroundLatLng: geolocation.stringForm,
          .hitsPerPage: hitsPerPage.flatMap(String.init),
          .language: language?.rawValue
          ])
        self.urlRequest = .init(method: .get, path: .places >>> PlacesCompletion.reverse, requestOptions: self.requestOptions)
      }

    }

  }

}
