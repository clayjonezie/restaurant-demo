//
//  ApplicationContext.swift
//  Restaurants
//
//  Created by Clay on 12/11/18.
//  Copyright © 2018 clay. All rights reserved.
//

import Foundation
import CoreLocation

protocol ApplicationContextDelegate {
  
  func didUpdateLocation(location: CLLocation)
  
}

class ApplicationContext: NSObject {
  
  public let locationManager: CLLocationManager
  public let apiClient: ApiClient
  public var delegate: ApplicationContextDelegate?
  
  override init() {
    self.locationManager = CLLocationManager()
    self.apiClient = ApiClient()
  
    super.init()
    
    locationManager.delegate = self
    self.locationManager.pausesLocationUpdatesAutomatically = true
    self.locationManager.activityType = CLActivityType.other
  }
  
  // begins tracking via 'significant-change location service'
  // @returns success of significant-change tracking
  func beginTrackingLocation() -> Bool {
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    return true
  }
  
}

extension ApplicationContext: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let last = locations.last {
      self.delegate?.didUpdateLocation(location: last)
    }
  }
  
}
