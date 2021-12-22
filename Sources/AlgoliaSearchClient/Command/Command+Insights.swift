//
//  Command+Insights.swift
//  
//
//  Created by Vladislav Fitc on 23/04/2020.
//

import Foundation

extension Command {

  enum Insights {

    struct SendEvents: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path = URL.eventsV1
      let body: Data?
      let requestOptions: RequestOptions?

      init(events: [InsightsEvent], requestOptions: RequestOptions?) {
        var requestOptions = requestOptions.unwrapOrCreate()
        requestOptions.setHeader("application/json", forKey: .contentType)
        self.requestOptions = requestOptions
        self.body = EventsWrapper(events).httpBody
      }

    }

  }

}
