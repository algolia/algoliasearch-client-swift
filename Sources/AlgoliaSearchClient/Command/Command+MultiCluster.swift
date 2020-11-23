//
//  Command+MultiCluster.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum MultiCluster {

    struct ListClusters: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = Path.clustersV1
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

    struct HasPendingMapping: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(retrieveMapping: Bool, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions.updateOrCreate([.getClusters: String(retrieveMapping)])
        let path = .clustersV1 >>> .mapping >>> MappingCompletion.pending
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

  }

}

extension Command.MultiCluster {

  enum User {

    struct Assign: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(userID: UserID, clusterName: ClusterName, requestOptions: RequestOptions?) {
        var updatedRequestOptions = requestOptions ?? .init()
        updatedRequestOptions.setHeader(userID.rawValue, forKey: .algoliaUserID)
        self.requestOptions = updatedRequestOptions
        let path = .clustersV1 >>> MappingRoute.mapping
        let body = ClusterWrapper(clusterName).httpBody
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: self.requestOptions)
      }

    }

    struct BatchAssign: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(userIDs: [UserID], clusterName: ClusterName, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .clustersV1 >>> .mapping >>> MappingCompletion.batch
        let body = AssignUserIDRequest(clusterName: clusterName, userIDs: userIDs).httpBody
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: self.requestOptions)
      }

    }

    struct Get: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(userID: UserID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .clustersV1 >>> .mapping >>> MappingCompletion.userID(userID)
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

    struct GetTop: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .clustersV1 >>> .mapping >>> MappingCompletion.top
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

    struct GetList: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(page: Int?, hitsPerPage: Int?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions.updateOrCreate(
          [
            .page: page.flatMap(String.init),
            .hitsPerPage: hitsPerPage.flatMap(String.init)
          ])
        let path = .clustersV1 >>> MappingRoute.mapping
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

    struct Remove: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(userID: UserID, requestOptions: RequestOptions?) {
        var updatedRequestOptions = requestOptions ?? .init()
        updatedRequestOptions.setHeader(userID.rawValue, forKey: .algoliaUserID)
        self.requestOptions = updatedRequestOptions
        let path = .clustersV1 >>> MappingRoute.mapping
        urlRequest = .init(method: .delete, path: path, requestOptions: self.requestOptions)
      }

    }

    struct Search: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(userIDQuery: UserIDQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .clustersV1 >>> .mapping >>> MappingCompletion.search
        urlRequest = .init(method: .post, path: path, body: userIDQuery.httpBody, requestOptions: self.requestOptions)
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
