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
  
  let urlSession: URLSession
  
  init() {
    self.urlSession = URLSession()
  }
  
  func requestRestaurants(with query: String?, location: CLLocation, completion: @escaping () -> Void) {
    if let url = self.googlePlacesUrl(for: query, location: location) {
      self.urlSession.dataTask(with: url) { (maybeData, maybeUrlResponse, maybeError) in
        completion()
      }
    }
  }
  
  func googlePlacesUrl(for query: String?, location: CLLocation) -> URL? {
    let formattedLocation = "point:\(location.coordinate.latitude),\(location.coordinate.latitude)"
    return URL(string:
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?" +
      "key=AIzaSyC9iT33vKT-pb7Lrok97X5aNPhGlY6iDBo" +
      "&inputtype=textquery" +
      "&input=\(query ?? "")" + // todo avoid if nil
      "&locationbias=\(formattedLocation)")
  }
  
  
}
