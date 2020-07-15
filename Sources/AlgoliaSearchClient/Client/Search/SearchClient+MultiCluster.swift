//
//  SearchClient+MultiCluster.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public extension SearchClient {
  
  // MARK: - List clusters
  
  /**
   List the Cluster available in a multi-clusters setup for a single ApplicationID.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func listClusters(requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultCallback<ClustersListResponse>) -> Operation {
    let command = Command.MultiCluster.ListClusters(requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   List the Cluster available in a multi-clusters setup for a single ApplicationID.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ClustersListResponse  object
   */
  @discardableResult func listClusters(requestOptions: RequestOptions? = nil) throws -> ClustersListResponse {
    let command = Command.MultiCluster.ListClusters(requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - List User IDs
  
  /**
   List the UserID assigned to a multi-clusters ApplicationID.
   
   The data returned will usually be a few seconds behind real-time, because UserID usage may take up to a few seconds to propagate to the different clusters.
   
   - Parameter page: Page to fetch.
   - Parameter hitsPerPage: Number of users to retrieve per page.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func listUsers(page: Int? = nil,
                                    hitsPerPage: Int? = nil,
                                    requestOptions: RequestOptions? = nil,
                                    completion: @escaping ResultCallback<UserIDListResponse>) -> Operation {
    let command = Command.MultiCluster.User.GetList(page: page, hitsPerPage: hitsPerPage, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   List the UserID assigned to a multi-clusters ApplicationID.
   
   The data returned will usually be a few seconds behind real-time, because UserID usage may take up to a few seconds to propagate to the different clusters.
   
   - Parameter page: Page to fetch.
   - Parameter hitsPerPage: Number of users to retrieve per page.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: UserIDListResponse  object
   */
  @discardableResult func listUsers(page: Int? = nil,
                                    hitsPerPage: Int? = nil,
                                    requestOptions: RequestOptions? = nil) throws -> UserIDListResponse {
    let command = Command.MultiCluster.User.GetList(page: page, hitsPerPage: hitsPerPage, requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Assign UserID
  /**
   Assign or Move a UserID to a cluster.
   
   The time it takes to migrate (move) a user is proportional to the amount of data linked to the UserID.
   If UserID is unknown, we will assign the UserID to the cluster, otherwise the operation will move the UserID and its associated data from its current cluster to the new one specified by ClusterName.
   
   - Parameter userID: UserID to assign.
   - Parameter clusterName: The ClusterName destination.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func assignUser(withID userID: UserID,
                                     toClusterWithName clusterName: ClusterName,
                                     requestOptions: RequestOptions? = nil,
                                     completion: @escaping ResultCallback<Creation>) -> Operation {
    let command = Command.MultiCluster.User.Assign(userID: userID, clusterName: clusterName, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Assign or Move a UserID to a cluster.
   
   The time it takes to migrate (move) a user is proportional to the amount of data linked to the UserID.
   If UserID is unknown, we will assign the UserID to the cluster, otherwise the operation will move the UserID and its associated data from its current cluster to the new one specified by ClusterName.
   
   - Parameter userID: UserID to assign.
   - Parameter clusterName: The ClusterName destination.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Creation  object
   */
  @discardableResult func assignUser(withID userID: UserID,
                                     toClusterWithName clusterName: ClusterName,
                                     requestOptions: RequestOptions? = nil) throws -> Creation {
    let command = Command.MultiCluster.User.Assign(userID: userID, clusterName: clusterName, requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Assign UserIDs
  
  /**
   Assign or move UserIDs to a ClusterName.
   
   The time it takes to migrate (move) a user is proportional to the amount of data linked to each UserID.
   
   - Parameter userIDs: List of UserID to save
   - Parameter clusterName: The ClusterName
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func assignUsers(withIDs userIDs: [UserID],
                                      toClusterWithName clusterName: ClusterName,
                                      requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<Creation>) -> Operation {
    let command = Command.MultiCluster.User.BatchAssign(userIDs: userIDs, clusterName: clusterName, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Assign or move UserIDs to a ClusterName.
   
   The time it takes to migrate (move) a user is proportional to the amount of data linked to each UserID.
   
   - Parameter userIDs: List of UserID to save
   - Parameter clusterName: The ClusterName
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Creation  object
   */
  @discardableResult func assignUsers(withIDs userIDs: [UserID],
                                      toClusterWithName clusterName: ClusterName,
                                      requestOptions: RequestOptions? = nil) throws -> Creation {
    let command = Command.MultiCluster.User.BatchAssign(userIDs: userIDs, clusterName: clusterName, requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Get UserID
  
  /**
   Returns the UserID data stored in the mapping.
   
   The data returned will usually be a few seconds behind real-time, because UserID usage may take up to a few seconds to propagate to the different clusters.
   
   - Parameter userID: UserID to fetch
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getUser(withID userID: UserID,
                                  requestOptions: RequestOptions? = nil,
                                  completion: @escaping ResultCallback<UserIDResponse>) -> Operation {
    let command = Command.MultiCluster.User.Get(userID: userID, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Returns the UserID data stored in the mapping.
   
   The data returned will usually be a few seconds behind real-time, because UserID usage may take up to a few seconds to propagate to the different clusters.
   
   - Parameter userID: UserID to fetch
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: UserIDResponse  object
   */
  @discardableResult func getUser(withID userID: UserID,
                                  requestOptions: RequestOptions? = nil) throws -> UserIDResponse {
    let command = Command.MultiCluster.User.Get(userID: userID, requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Get top UserID
  
  /**
   Get the top 10 ResponseUserID with the highest number of records per cluster.
   The data returned will usually be a few seconds behind real-time, because userID usage may take up to a few seconds to propagate to the different clusters.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getTopUser(requestOptions: RequestOptions? = nil,
                                     completion: @escaping ResultCallback<TopUserIDResponse>) -> Operation {
    let command = Command.MultiCluster.User.GetTop(requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Get the top 10 ResponseUserID with the highest number of records per cluster.
   The data returned will usually be a few seconds behind real-time, because userID usage may take up to a few seconds to propagate to the different clusters.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: TopUserIDResponse  object
   */
  @discardableResult func getTopUser(requestOptions: RequestOptions? = nil) throws -> TopUserIDResponse {
    let command = Command.MultiCluster.User.GetTop(requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Remove UserID
  
  /**
   Remove a UserID and its associated data from the multi-clusters.
   
   Even if the UserID doesn’t exist, the request to remove the UserID will still succeed because of the asynchronous handling of this request.
   
   - Parameter userID: UserID to remove.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func removeUser(withID userID: UserID,
                                     requestOptions: RequestOptions? = nil,
                                     completion: @escaping ResultCallback<Deletion>) -> Operation {
    let command = Command.MultiCluster.User.Remove(userID: userID, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Remove a UserID and its associated data from the multi-clusters.
   
   Even if the UserID doesn’t exist, the request to remove the UserID will still succeed because of the asynchronous handling of this request.
   
   - Parameter userID: UserID to remove.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Deletion  object
   */
  @discardableResult func removeUser(withID userID: UserID,
                                     requestOptions: RequestOptions? = nil) throws -> Deletion {
    let command = Command.MultiCluster.User.Remove(userID: userID, requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Search UserID
  
  /**
   Search for UserID.
   
   The data returned will usually be a few seconds behind real-time, because userID usage may take up to a few seconds propagate to the different clusters.
   
   - Parameter query: The UserID query
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func searchUser(with query: UserIDQuery,
                                     requestOptions: RequestOptions? = nil,
                                     completion: @escaping ResultCallback<UserIDSearchResponse>) -> Operation {
    let command = Command.MultiCluster.User.Search(userIDQuery: query, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Search for UserID.
   
   The data returned will usually be a few seconds behind real-time, because userID usage may take up to a few seconds propagate to the different clusters.
   
   - Parameter query: The UserID query
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: UserIDSearchResponse  object
   */
  @discardableResult func searchUser(with query: UserIDQuery,
                                     requestOptions: RequestOptions? = nil) throws -> UserIDSearchResponse {
    let command = Command.MultiCluster.User.Search(userIDQuery: query, requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Has pending mapping
  
  /**
   - Parameter retrieveMappings: If set to true, retrieves HasPendingMappingResponse.clusters.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func hasPendingMappings(retrieveMappings: Bool = false,
                                             requestOptions: RequestOptions? = nil,
                                             completion: @escaping ResultCallback<HasPendingMappingResponse>) -> Operation {
    let command = Command.MultiCluster.HasPendingMapping(retrieveMapping: retrieveMappings, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   - Parameter retrieveMappings: If set to true, retrieves HasPendingMappingResponse.clusters.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: HasPendingMappingResponse  object
   */
  @discardableResult func hasPendingMappings(retrieveMappings: Bool = false,
                                             requestOptions: RequestOptions? = nil) throws -> HasPendingMappingResponse {
    let command = Command.MultiCluster.HasPendingMapping(retrieveMapping: retrieveMappings, requestOptions: requestOptions)
    return try execute(command)
  }
  
}
