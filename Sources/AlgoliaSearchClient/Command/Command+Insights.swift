//
//  Command+Insights.swift
//  
//
//  Created by Vladislav Fitc on 23/04/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Insights {

    struct SendEvents: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(events: [InsightsEvent], requestOptions: RequestOptions?) {
        let body = EventsWrapper(events)
        var requestOptions = requestOptions.unwrapOrCreate()
        requestOptions.setHeader("application/json", forKey: .contentType)
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .post, path: Path.eventsV1, body: body.httpBody, requestOptions: self.requestOptions)
      }

    }

  }

}
