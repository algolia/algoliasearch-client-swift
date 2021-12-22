//
//  Command+MultiCluster.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

extension Command {

  enum MultiCluster {

    struct ListClusters: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path = URL.clustersV1
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
      }

    }

    struct HasPendingMapping: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: URL
      let requestOptions: RequestOptions?

      init(retrieveMapping: Bool, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions.updateOrCreate([.getClusters: String(retrieveMapping)])
        self.path = URL
          .clustersV1
          .appending(.mapping)
          .appending(.pending)
      }

    }

  }

}

extension Command.MultiCluster {

  enum User {

    struct Assign: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path = URL.clustersV1.appending(.mapping)
      let body: Data?
      let requestOptions: RequestOptions?

      init(userID: UserID, clusterName: ClusterName, requestOptions: RequestOptions?) {
        var updatedRequestOptions = requestOptions ?? .init()
        updatedRequestOptions.setHeader(userID.rawValue, forKey: .algoliaUserID)
        self.requestOptions = updatedRequestOptions
        self.body = ClusterWrapper(clusterName).httpBody
      }

    }

    struct BatchAssign: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: URL = URL
        .clustersV1
        .appending(.mapping)
        .appending(.batch)
      let body: Data?
      let requestOptions: RequestOptions?

      init(userIDs: [UserID], clusterName: ClusterName, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.body = AssignUserIDRequest(clusterName: clusterName, userIDs: userIDs).httpBody
      }

    }

    struct Get: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: URL
      let requestOptions: RequestOptions?

      init(userID: UserID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .clustersV1
          .appending(.mapping)
          .appending(userID)
      }

    }

    struct GetTop: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path = URL.clustersV1
        .appending(.mapping)
        .appending(.top)
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
      }

    }

    struct GetList: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path = URL.clustersV1
        .appending(.mapping)
      let requestOptions: RequestOptions?

      init(page: Int?, hitsPerPage: Int?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions.updateOrCreate(
          [
            .page: page.flatMap(String.init),
            .hitsPerPage: hitsPerPage.flatMap(String.init)
          ])
      }

    }

    struct Remove: AlgoliaCommand {

      let method: HTTPMethod = .delete
      let callType: CallType = .write
      let path: URL = URL
        .clustersV1
        .appending(.mapping)
      let requestOptions: RequestOptions?

      init(userID: UserID, requestOptions: RequestOptions?) {
        var updatedRequestOptions = requestOptions ?? .init()
        updatedRequestOptions.setHeader(userID.rawValue, forKey: .algoliaUserID)
        self.requestOptions = updatedRequestOptions
      }

    }

    struct Search: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path = URL.clustersV1
        .appending(.mapping)
        .appending(.search)
      let body: Data?
      let requestOptions: RequestOptions?

      init(userIDQuery: UserIDQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.body = userIDQuery.httpBody
      }

    }

  }

}

struct AssignUserIDRequest: Codable {

  let clusterName: ClusterName
  let userIDs: [UserID]

  enum CodingKeys: String, CodingKey {
    case clusterName = "cluster"
    case userIDs = "users"
  }

}
