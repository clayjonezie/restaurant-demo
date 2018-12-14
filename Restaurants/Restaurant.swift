//
//  Restaurant.swift
//  Restaurants
//
//  Created by Clay on 12/13/18.
//  Copyright © 2018 clay. All rights reserved.
//

import Foundation
import CoreLocation

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
  var opening_hours: RestaurantOpening?
  var vicinity: String?
  
  func clLocation2D() -> CLLocationCoordinate2D? {
    if let lat = self.geometry?.location?.lat,
      let lng = self.geometry?.location?.lng {
      return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
    }
    return nil
  }
  
  func formattedDescription() -> String {
    var components = [String]()
    
    if let rating = self.rating {
      components.append("\(rating) out of 5 stars")
    }
    
    if let price = self.price_level {
      components.append("price level: \(price)")
    }
    
    if let vicinity = self.vicinity {
      components.append(vicinity)
    }
    
    if let isOpen = self.opening_hours?.open_now {
      components.append(isOpen ? "Currently Open" : "Currently Closed")
    }
    
    return components.joined(separator: "\n")
  }
  
}

struct RestaurantGeometry: Codable {
  
  var location: DecodablePoint?
  
}

struct RestaurantOpening: Codable {
  
  var open_now: Bool
  
}

struct DecodablePoint: Codable {
  
  var lat: Double?
  var lng: Double?
  
}
