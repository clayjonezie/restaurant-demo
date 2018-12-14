//
//  ApiClient.swift
//  Restaurants
//
//  Created by Clay on 12/11/18.
//  Copyright © 2018 clay. All rights reserved.
//

import Foundation
import CoreLocation

public class ApiClient {
  
  enum Constant {
    static let defaultRadius = 1500
  }
  
  func requestNearbyRestaurants(for location: CLLocation,
                                keyword: String? = nil,
                                radius: Int = Constant.defaultRadius,
                                completion: @escaping (RestaurantsResult?, Error?) -> Void) {
    if let url = self.nearbyRestaurantsQuery(for: location, keyword: keyword, radius: radius) {
      let task = URLSession.shared.dataTask(with: url) { (maybeData, maybeUrlResponse, maybeError) in
        if let data = maybeData {
          var results: RestaurantsResult?
          var returnedError: Error?
          do {
            try results = JSONDecoder().decode(RestaurantsResult.self, from: data)
          } catch {
            returnedError = error
          }
          DispatchQueue.main.async {
            completion(results, returnedError)
          }
        } else {
          completion(nil, maybeError)
        }
      }
      task.resume()
    }
  }
  
  func nearbyRestaurantsQuery(for location: CLLocation,
                              keyword: String? = nil,
                              radius: Int) -> URL? {
    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?" +
      "key=AIzaSyC9iT33vKT-pb7Lrok97X5aNPhGlY6iDBo" +
      "&location=\(location.formatted)" +
      "&radius=\(radius)" +
     "&type=restaurant"
    
    if let keyword = keyword {
      urlString.append("&keyword=\(keyword)")
    }
    return URL(string: urlString)
  }
  
}

extension CLLocation {
  
  var formatted: String {
    return "\(self.coordinate.latitude),\(self.coordinate.longitude)"
  }
  
}
