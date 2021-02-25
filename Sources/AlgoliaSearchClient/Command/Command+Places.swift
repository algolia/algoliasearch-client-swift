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

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: PlacesCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(query: PlacesQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.places >>> .query)
        self.body = query.httpBody
      }

    }

    struct GetObject: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: PlacesCompletion
      let requestOptions: RequestOptions?

      init(objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.places >>> .objectID(objectID))
      }

    }

    struct ReverseGeocoding: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: PlacesCompletion
      let requestOptions: RequestOptions?

      init(geolocation: Point, language: Language?, hitsPerPage: Int?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions.updateOrCreate([
          .aroundLatLng: geolocation.stringForm,
          .hitsPerPage: hitsPerPage.flatMap(String.init),
          .language: language?.rawValue
          ])
        self.path = (.places >>> .reverse)
      }

    }

  }

}
