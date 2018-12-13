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
  
  func requestNearbyRestaurants(for location: CLLocation, completion: @escaping (RestaurantsResult?, Error?) -> Void) {
    if let url = self.nearbyRestaurantsQuery(for: location) {
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
  
  func nearbyRestaurantsQuery(for location: CLLocation) -> URL? {
    return URL(string:
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?" +
        "key=AIzaSyC9iT33vKT-pb7Lrok97X5aNPhGlY6iDBo" +
//        "&location=\(location.formatted)" +
        "&location=37.454822,-122.220637" +
        "&radius=1500" +
        
        // use keyword
      "&type=restaurant")
  }
  
  func googlePlacesUrl(for query: String?, location: CLLocation) -> URL? {
    return URL(string:
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?" +
      "key=AIzaSyC9iT33vKT-pb7Lrok97X5aNPhGlY6iDBo" +
      "&inputtype=textquery" +
//      "&input=\(query ?? "")" + // todo avoid if nil
      "&locationbias=point:\(location.formatted)")
  }
  
  
}

extension CLLocation {
  
  var formatted: String {
    return "\(self.coordinate.latitude),\(self.coordinate.latitude)"
  }
  
}
