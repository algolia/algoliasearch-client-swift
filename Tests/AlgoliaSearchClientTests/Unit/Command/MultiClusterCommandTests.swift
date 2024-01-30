//
//  MultiClusterCommandTest.swift
//
//
//  Created by Vladislav Fitc on 26/05/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class MultiClusterCommandTest: XCTestCase, AlgoliaCommandTest {
  func testListIndices() {
    let command = Command.MultiCluster.ListClusters(requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .read,
      method: .get,
      urlPath: "/1/clusters",
      queryItems: [.init(name: "testParameter", value: "testParameterValue")],
      body: nil,
      requestOptions: test.requestOptions)
  }

  func testAssignUserID() {
    let command = Command.MultiCluster.User.Assign(
      userID: test.userID, clusterName: test.clusterName, requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .write,
      method: .post,
      urlPath: "/1/clusters/mapping",
      queryItems: [.init(name: "testParameter", value: "testParameterValue")],
      body: ClusterWrapper(test.clusterName).httpBody,
      additionalHeaders: ["X-Algolia-User-ID": test.userID.rawValue],
      requestOptions: test.requestOptions)
  }

  func testGetUserID() {
    let command = Command.MultiCluster.User.Get(
      userID: test.userID, requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .read,
      method: .get,
      urlPath: "/1/clusters/mapping/\(test.userID)",
      queryItems: [.init(name: "testParameter", value: "testParameterValue")],
      body: nil,
      requestOptions: test.requestOptions)
  }

  func testGetTopUserID() {
    let command = Command.MultiCluster.User.GetTop(requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .read,
      method: .get,
      urlPath: "/1/clusters/mapping/top",
      queryItems: [.init(name: "testParameter", value: "testParameterValue")],
      body: nil,
      requestOptions: test.requestOptions)
  }

  func testGetUserIDList() {
    let command = Command.MultiCluster.User.GetList(
      page: 10, hitsPerPage: 100, requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .read,
      method: .get,
      urlPath: "/1/clusters/mapping",
      queryItems: [
        .init(name: "testParameter", value: "testParameterValue"),
        .init(name: "page", value: "10"),
        .init(name: "hitsPerPage", value: "100"),
      ],
      body: nil,
      requestOptions: test.requestOptions)
  }

  func testRemoveUserID() {
    let command = Command.MultiCluster.User.Remove(
      userID: test.userID, requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .write,
      method: .delete,
      urlPath: "/1/clusters/mapping",
      queryItems: [
        .init(name: "testParameter", value: "testParameterValue")
      ],
      body: nil,
      additionalHeaders: ["X-Algolia-User-ID": test.userID.rawValue],
      requestOptions: test.requestOptions)
  }

  func testSearchUserID() {
    let command = Command.MultiCluster.User.Search(
      userIDQuery: "testQuery", requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .read,
      method: .post,
      urlPath: "/1/clusters/mapping/search",
      queryItems: [
        .init(name: "testParameter", value: "testParameterValue")
      ],
      body: UserIDQuery().set(\.query, to: "testQuery").httpBody,
      requestOptions: test.requestOptions)
  }

  func testAssignUserIDs() {
    let command = Command.MultiCluster.User.BatchAssign(
      userIDs: ["u1", "u2"], clusterName: test.clusterName, requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .write,
      method: .post,
      urlPath: "/1/clusters/mapping/batch",
      queryItems: [
        .init(name: "testParameter", value: "testParameterValue")
      ],
      body: AssignUserIDRequest(clusterName: test.clusterName, userIDs: ["u1", "u2"]).httpBody,
      requestOptions: test.requestOptions)
  }

  func testHasPendingMapping() {
    let command = Command.MultiCluster.HasPendingMapping(
      retrieveMapping: true, requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .read,
      method: .get,
      urlPath: "/1/clusters/mapping/pending",
      queryItems: [
        .init(name: "testParameter", value: "testParameterValue"),
        .init(name: "getClusters", value: "true"),
      ],
      body: nil,
      requestOptions: test.requestOptions)
  }
}
