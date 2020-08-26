//
//  IndexingSnippets.swift
//  
//
//  Created by Vladislav Fitc on 28/06/2020.
//

import Foundation
import AlgoliaSearchClient

struct IndexingSnippets: SnippetsCollection {}

//MARK: - Save objects

extension IndexingSnippets {
  
  static var saveObjectsGeneratingObjectID = """
  index.saveObjects<T: Encodable>(
    _ #{objects}: __[T]__ ,
    autoGeneratingObjectID: __Bool__ = false,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<BatchesResponse>> -> Void__
  ) throws

  // add a single object

  index.saveObject<T: Encodable>(
    _ #{object}: __T__ ,
    autoGeneratingObjectID: __Bool__ = false,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<ObjectCreation> -> Void__
  ) throws
  """
  
  func saveObjectsGeneratingObjectID() throws {
    
    struct Contact: Encodable {
      let firstname: String
      let lastname: String
    }
    
    let contacts: [Contact] = [
      .init(firstname: "Jimmie", lastname: "Barninger"),
      .init(firstname: "Warren", lastname: "Speach"),
    ]
    
    index.saveObjects(contacts, autoGeneratingObjectID: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func saveObjectsSettingObjectID() throws {
    struct Contact: Encodable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    let contacts: [Contact] = [
      .init(objectID: "myID1", firstname: "Jimmie", lastname: "Barninger"),
      .init(objectID: "myID2", firstname: "Warren", lastname: "Speach"),
    ]
    
    index.saveObjects(contacts) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func saveObject() throws {
    struct Contact: Encodable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    let contact: Contact = .init(objectID: "myID1", firstname: "Jimmie", lastname: "Barninger")

    index.saveObject(contact) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func saveObjectsSettingObjectIDWithExtraHeaders() throws {
    struct Contact: Encodable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-User-ID"] = "user123"
    
    let contacts: [Contact] = [
      .init(objectID: "myID1", firstname: "Jimmie", lastname: "Barninger"),
      .init(objectID: "myID2", firstname: "Warren", lastname: "Speach"),
    ]

    index.saveObjects(contacts, requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Replace objects

extension IndexingSnippets {
  
  static var replaceObjects = """
  index.replaceObjects<T: Encodable>(
    [replacements](#method-param-objects): __[(ObjectID, T)]__ ,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<BatchesResponse>> -> Void__,
  )

  // update a single object
  index.replaceObject<T: Encodable>(
    withID objectID: ObjectID,
    _ #{object}: __T__ ,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<ObjectRevision> -> Void__,
  )
  """
  
  func replaceObjects() throws {
    struct Contact: Encodable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    let contacts: [Contact] = [
      .init(objectID: "myID1", firstname: "Jimmie", lastname: "Barninger"),
      .init(objectID: "myID2", firstname: "Warren", lastname: "Speach"),
    ]
    
    let replacements = contacts.map {($0.objectID, $0) }
    
    index.replaceObjects(replacements: replacements) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func replaceObject() throws {
    struct Contact: Encodable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
      let city: String
    }
    
    let contact: Contact = .init(objectID: "myID1", firstname: "Jimmie", lastname: "Barninger", city: "New York")

    index.replaceObject(withID: contact.objectID, by: contact) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func replaceObjectsWithExtraHeaders() throws {
    struct Contact: Encodable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-User-ID"] = "user123"
    
    let contacts: [Contact] = [
      .init(objectID: "myID1", firstname: "Jimmie", lastname: "Barninger"),
      .init(objectID: "myID2", firstname: "Warren", lastname: "Speach"),
    ]
    let replacements: [(ObjectID, Contact)] = contacts.map { ($0.objectID, $0) }
    
    index.replaceObjects(replacements: replacements, requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func overrideBatchSize() {
    let configuration = SearchConfiguration(applicationID: "YourApplicationID", apiKey: "YourAdminAPIKey")
      .set(\.batchSize, to: 999999)
    let client = SearchClient(configuration: configuration)
    _ = client//to remove when pasted to doc
  }
  
}

//MARK: - Partial Update

extension IndexingSnippets {
  
  static var partialUpdate = """
  index.partialUpdateObjects(
    [updates](#method-param-objects): __[(ObjectID, PartialUpdate)]__ ,
    #{createIfNotExists}: __Bool__ = true,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<BatchesResponse> -> Void__
  )
  
  // update a single object
  index.partialUpdateObject(
    withID #{objectID}: ObjectID,
    with partialUpdate: __PartialUpdate__,
    #{createIfNotExists}: __Bool__ = true,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<ObjectRevision> -> Void__
  )
  """
  
  func partialUpdate() {
    index.partialUpdateObject(withID: "myID", with: .update(attribute: "city", value: "San Francisco")) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func partialUpdateAdd() {
    index.partialUpdateObject(withID: "myID", with: .update(attribute: "state", value: "California")) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func partialBatchUpdate() {
    let updates: [(ObjectID, PartialUpdate)] = [
      ("myID1", .update(attribute: "firstname", value: "Jimmie")),
      ("myID2", .update(attribute: "firstname", value: "Warren"))
    ]
    
    index.partialUpdateObjects(updates: updates) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func partialBatchUpdateWithExtraHeaders() {
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-User-ID"] = "user123"

    let updates: [(ObjectID, PartialUpdate)] = [
      ("myID1", .update(attribute: "firstname", value: "Jimmie")),
      ("myID2", .update(attribute: "firstname", value: "Warren"))
    ]
    
    index.partialUpdateObjects(updates: updates, requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func increment_existing_partial() {
    index.partialUpdateObject(withID: "myID", with: .increment(attribute: "count", value: 2)) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func addunique_existing_partial() {
    index.partialUpdateObject(withID: "myID", with: .add(attribute: "_tags", value: "public", unique: true)) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func increment_from() {
    index.partialUpdateObject(withID: "myID", with: .incrementFrom(attribute: "version", value: 2)) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func increment_set() {
    index.partialUpdateObject(withID: "myID", with: .incrementSet(attribute: "lastmodified", value: 1593431913)) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }

}

//MARK: - Delete Objects Update

extension IndexingSnippets {
  
  static var deleteObjects = """
  index.deleteObjects(
    withIDs #{objectIDs}: __[ObjectID]__,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<BatchesResponse> -> Void__
  )
  
  // delete a single object
  index.deleteObject(
    withID #{objectID}: ObjectID ,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<ObjectDeletion> -> Void__
  )
  """
  
  func deleteObjects() {
    index.deleteObjects(withIDs: ["myID1", "myID2"]) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func deleteObjectsWithExtraHeaders() {
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-User-ID"] = "user123"
    
    index.deleteObjects(withIDs: ["myID"], requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func deleteObject() {
    index.deleteObject(withID: "myID") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Replace All Objects

extension IndexingSnippets {
  
  static var replaceAllObjects = """
  index.replaceAllObjects<T: Encodable>(
    with #{objects}: __[T]__,
    autoGeneratingObjectID: __Bool__ = false,
    #{safe}: __Bool__ = false,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<[TaskIndex]> -> Void__
  ) throws
  """
  
  func replaceAllObjects() throws {
    
    struct Contact: Encodable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    let client = SearchClient(appID: "YourApplicationID", apiKey: "YourAdminAPIKey")
    let index = client.index(withName: "your_index_name")
    
    let objects: [Contact]! = [/*Fetch your objects*/]

    index.replaceAllObjects(with: objects) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
    
  }
  
  func replaceAllObjectsSafe() throws {
    
    struct Contact: Encodable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    let client = SearchClient(appID: "YourApplicationID", apiKey: "YourAdminAPIKey")
    let index = client.index(withName: "your_index_name")
    
    let objects: [Contact]! = [/*Fetch your objects*/]

    index.replaceAllObjects(with: objects, safe: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
    
  }
  
}

//MARK: - Delete by Query

extension IndexingSnippets {
  
  static var deleteBy = """
  index.deleteObjects(
    byQuery query: __DeleteByQuery__,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<IndexRevision> -> Void__
  )

  // set any #{filterParameters} on the DeleteByQuery object
  """
  
  func deleteBy() {
    var query = DeleteByQuery()

    query.filters = "category:cars"
    query.aroundLatLng = .init(latitude: 40.71, longitude: -74.01)

    index.deleteObjects(byQuery: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func deleteByQueryWithExtraHeaders() {
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-User-ID"] = "user123"
    
    var query = DeleteByQuery()

    query.filters = "category:cars"
    query.aroundLatLng = .init(latitude: 40.71, longitude: -74.01)

    index.deleteObjects(byQuery: query, requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Clear Index

extension IndexingSnippets {
  
  static var clearIndex = """
  index.clearObjects(
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<IndexRevision> -> Void__
  )
  """
  
  func clearIndex() {
    index.clearObjects { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Get Objects

extension IndexingSnippets {
  
  static var getObjects = """
  index.getObjects<T: Decodable>(
    withIDs #{objectIDs}: __[ObjectID]__,
    #{attributesToRetrieve}: __[Attribute]__ = [],
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<ObjectsResponse<T>> -> Void__
  )
    
  // get a single object
  index.getObject(
    withID #{objectID}: __ObjectID__,
    #{attributesToRetrieve}: __[Attribute]__ = [],
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<T> -> Void__
  )

  // get multiple objects
  client.multipleGetObjects(
    requests: __[ObjectRequest]__,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<ObjectsResponse<T>> -> Void__
  )
  """
  
  func getObjects() {
    struct Contact: Codable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }

    index.getObjects(withIDs: ["myId1", "myId2"]) { (result: Result<ObjectsResponse<Contact>, Error>) in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func getObjectsWithAttributes() {
    struct Contact: Codable {
      let firstname: String
    }

    index.getObjects(withIDs: ["myId1", "myId2"], attributesToRetrieve: ["firstname"]) { (result: Result<ObjectsResponse<Contact>, Error>) in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func getObjectsWithExtraHeaders() {
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-User-ID"] = "user123"
    
    struct Contact: Codable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }

    index.getObjects(withIDs: ["myId1", "myId2"], requestOptions: requestOptions) { (result: Result<ObjectsResponse<Contact>, Error>) in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func getObject() {
    
    struct Contact: Codable {
      let firstname: String
      let lastname: String?
    }

    // Retrieve all attributes.
    index.getObject(withID: "myId") { (result: Result<Contact, Error>) in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }

    // Retrieves `firstname` and `lastname` attributes.
    index.getObject(withID: "myId",
                    attributesToRetrieve: ["firstname", "lastname"]) { (result: Result<Contact, Error>) in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }

    // Retrieve only the `firstname` attribute.
    index.getObject(withID: "myId",
                    attributesToRetrieve: ["firstname"]) { (result: Result<Contact, Error>) in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }

  }
  
  func multipleGetObjects() {
    
    let requests: [ObjectRequest] = [
      .init(indexName: "index1", objectID: "myId1"),
      .init(indexName: "index2", objectID: "myId2"),
    ]
    
    client.multipleGetObjects(requests: requests) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
    
  }
  
}

//MARK: - Multiple Batch Objects

extension IndexingSnippets {
  
  static var customBatch = """
  client.batch(
    #{operations}: __[(IndexName, BatchOperation)]__,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<BatchesResponse>> -> Void__
  )
  """
  
  func batchMultipleIndices() throws {
    struct Contact: Codable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    let operations: [(IndexName, BatchOperation)] = [
      ("index1", .add(Contact(objectID: "myID1", firstname: "Jimmie", lastname: "Barninger"))),
      ("index1", .update(objectID: "myID2", Contact(objectID: "myID2", firstname: "Max", lastname: "Barninger"))),
      ("index1", .partialUpdate(objectID: "myID3", ["lastname": "McFarway"] as JSON, createIfNotExists: true)),
      ("index1", .partialUpdate(objectID: "myID4", ["firstname": "Warren"] as JSON, createIfNotExists: false)),
      ("index2", .delete(objectID: "myID5"))
    ]
    
    client.multipleBatchObjects(operations: operations) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func batchMultipleIndicesExtraHeaders() throws {
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-User-ID"] = "user123"

    struct Contact: Codable {
      let objectID: ObjectID
      let firstname: String
      let lastname: String
    }
    
    let operations: [(IndexName, BatchOperation)] = [
      ("index1", .add(Contact(objectID: "myID1", firstname: "Jimmie", lastname: "Barninger"))),
      ("index2", .add(Contact(objectID: "myID2", firstname: "Warren", lastname: "Speach")))
    ]
    
    client.multipleBatchObjects(operations: operations, requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}
