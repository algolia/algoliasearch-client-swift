import Foundation
import AlgoliaSearch
import Combine

@available(iOS 13, *)
class AlgoliaPublisher<HitType : Codable>: ObservableObject {
  typealias SuccessType = AlgoliaQueryResponse<HitType>
  typealias CompletionType = (SuccessType?) -> ()
  
  private let completion : CompletionType
  private let client : Client
  private let index : Index

  let objectWillChange = PassthroughSubject<SuccessType?, Never>()
  public var response : SuccessType? = nil {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.objectWillChange.send(self?.response)
      }
    }
  }

  
  private func convertResponse(
    _ responseDictionary : [String: Any]?
  ) -> SuccessType? {
    do {
      guard let responseObject = responseDictionary else { return nil }
      let jsonData = try JSONSerialization.data(withJSONObject: responseObject, options: [])
      let response = try JSONDecoder().decode(SuccessType.self, from: jsonData)
      return response
    } catch {
      print(error.localizedDescription)
    }
    return nil
  }
  
  private func startSearch(
    query : Query,
    requestOptions : RequestOptions
  ) {
    index.search(query, requestOptions: requestOptions) { (responseDictionnary, err) in
      
      let obj = self.convertResponse(responseDictionnary)
      self.response = obj
      self.completion(obj)
      
      if let error = err { print(error.localizedDescription) }
    }
  }
  
  public init(
    _ query : Query,
    requestOptions : RequestOptions = RequestOptions(),
    client : Client,
    index : Index,
    completion : @escaping CompletionType
  ) {
    self.client = client
    self.index = index
    self.completion = completion
    startSearch(query: query, requestOptions: requestOptions)
  }
}
