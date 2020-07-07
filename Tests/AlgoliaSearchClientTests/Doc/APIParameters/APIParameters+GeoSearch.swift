//
//  APIParameters+GeoSearch.swift
//  
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import Foundation
import AlgoliaSearchClient

extension APIParameters {
  //MARK: - GeoSearch
  func geoSearch() {
    func aroundLatLng() {
      /*
       aroundLatLng = Point(latitude, longitude)
       */
      
      func search_around_a_position() {
        let query = Query("query")
          .set(\.aroundLatLng, to: Point(latitude: 40.71, longitude: -74.01))
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    
    func aroundLatLngViaIP() {
      /*
       aroundLatLngViaIP = true|false
       */
      
      func search_around_server_ip() {
        /// '94.228.178.246' should be replaced with the actual IP you would like
        /// to search around. Depending on your stack there are multiple ways to get this
        /// information.
        let configuration = SearchConfiguration(
          applicationID: "YourApplicationID",
          apiKey: "YourSearchOnlyAPIKey"
        )
          .set(\.defaultHeaders, to: ["X-Forwarded-For": "94.228.178.246"])
        let client = SearchClient(configuration: configuration)
        let index = client.index(withName: "index_name")
        
        let query = Query("query")
          .set(\.aroundLatLngViaIP, to: true)
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    
    func aroundRadius() {
      /*
       aroundRadius = .meters(#{radius_in_meters})|.#{all}
       */
      
      func set_around_radius() {
        let query = Query("query")
          .set(\.aroundRadius, to: .meters(1000))
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func disable_automatic_radius() {
        let query = Query("query")
          .set(\.aroundRadius, to: .all)
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    
    func aroundPrecision() {
      /*
       aroundPrecision = number_of_meters
       */
      
      func set_geo_search_precision() {
        let query = Query("query")
          .set(\.aroundPrecision, to: [100]) // 100 meters precision
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func set_geo_search_precision_non_linear() {
        let query = Query("query")
          .set(\.aroundPrecision, to: [
            .init(from: 0, value: 25), // 25 meters precision by default
            .init(from: 2000, value: 1000) // 1,000 meters precision after 2 km
          ])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
    }
    
    func minimumAroundRadius() {
      /*
       minimumAroundRadius = radius
       */
      
      func set_minimum_geo_search_radius() {
        let query = Query("query")
          .set(\.minimumAroundRadius, to: 1000) // 1km
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    
    func insideBoundingBox() {
      /*
       insideBoundingBox = [
       BoundingBox(
       point1: Point(latitude: point1_lat, longitude: point1_lng),
       point2: Point(latitude: point2_lat, longitude: point2_lng)
       ),
       BoundingBox( // you can search in multiple rectangles
       ...
       )
       ]
       */
      
      func search_inside_rectangular_area() {
        let query = Query("query")
          .set(\.insideBoundingBox, to: [
            BoundingBox(point1: (46.650828100116044, 7.123046875),
                        point2: (45.17210966999772, 1.009765625))
          ])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func search_inside_multiple_rectangular_areas() {
        
        let boundingBox1 = BoundingBox(
          point1: (46.650828100116044, 7.123046875),
          point2: (45.17210966999772, 1.009765625)
        )
        
        let boundingBox2 = BoundingBox(
          point1: (49.62625916704081, 4.6181640625),
          point2: (47.715070300900194, 0.482421875)
        )
        
        let query = Query("query")
          .set(\.insideBoundingBox, to: [boundingBox1, boundingBox2])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
        
      }
    }
    
    func insidePolygon() {
      /*
       insidePolygon = [
       [Polygon](#parameter-option-a-polygon)(
       point1: Point,
       point2: Point,
       point3: Point,
       ...
       ),
       Polygon(// you can search in #{multiple polygons})
       ]
       */
      
      func search_inside_polygon_area() {
        let polygon = Polygon(
          (46.650828100116044, 7.123046875),
          (45.17210966999772, 1.009765625),
          (49.62625916704081, 4.6181640625),
          (47.715070300900194, 0.482421875)
        )
        
        let query = Query("query")
          .set(\.insidePolygon, to: [polygon])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func search_inside_multiple_polygon_areas() {
        
        let polygon1 = Polygon(
          (46.650828100116044, 7.123046875),
          (45.17210966999772, 1.009765625),
          (49.62625916704081, 4.6181640625),
          (47.715070300900194, 0.482421875)
        )
        
        let polygon2 = Polygon(
          (47.650828100116044, 6.123046875),
          (46.17210966999772, 1.009765625),
          (48.62625916704081, 3.6181640625),
          (45.715070300900194, 0.482421875)
        )
        
        let query = Query("query")
          .set(\.insidePolygon, to: [
            polygon1,
            polygon2
          ])
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
        
      }
    }
    
  }
}
