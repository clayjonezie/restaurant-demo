//
//  Restaurant.swift
//  Restaurants
//
//  Created by Clay on 12/13/18.
//  Copyright © 2018 clay. All rights reserved.
//

import Foundation
import CoreLocation

/*
 Other interesting fields:
   geometry.viewport
   vicinity
   opening_hours
 */

struct RestaurantsResult: Codable {
  
  var results: [Restaurant]
  
}

struct Restaurant: Codable {
  
  var id: String?
  var place_id: String?
  var geometry: RestaurantGeometry?
  var price_level: Int?
  var rating: Float?
  var name: String?
  
  func clLocation2D() -> CLLocationCoordinate2D? {
    if let lat = self.geometry?.location?.lat,
      let lng = self.geometry?.location?.lng {
      return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
    }
    return nil
  }
  
}

struct RestaurantGeometry: Codable {
  
  var location: DecodablePoint?
  
}

struct DecodablePoint: Codable {
  
  var lat: Double?
  var lng: Double?
  
}
