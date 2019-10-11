import Foundation

@available(iOS 13, *)
struct AlgoliaQueryResponse<HitType : Codable> : Codable {
  typealias HitsType = [HitType]
  
  let nbPages : Int
  let page : Int
  let nbHits : Int
  let exhaustiveNbHits : Bool
  let hitsPerPage : Int
  let hits : HitsType
  let params : String
  let query : String
  let processingTimeMS : Int
}
