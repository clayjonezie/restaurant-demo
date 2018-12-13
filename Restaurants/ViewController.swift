//
//  ViewController.swift
//  Restaurants
//
//  Created by Clay on 12/11/18.
//  Copyright © 2018 clay. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapResultsViewController: UIViewController {

  let appContext: ApplicationContext
  var hasSubmittedInitialQuery = false
  var userLocationMarkerView: MKMarkerAnnotationView?
  var currentAnnotations: [MKAnnotation]

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  required init?(coder aDecoder: NSCoder) {
    appContext = ApplicationContext()
    self.currentAnnotations = []

    super.init(coder: aDecoder)
    
    self.appContext.delegate = self
  }
  
  override func viewDidLoad() {
    self.mapView.showsUserLocation = true
    self.mapView.userLocation.title = nil
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    switch authorizationStatus {
    case .restricted:
      self.presentLocationDisabledAlert(with: "This appears to be due to a restriction placed on your device.")
    case .denied:
      self.presentLocationDisabledAlert(with: "You can grant this application access to your location in Settings.")
    case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
      _ = self.appContext.beginTrackingLocation()
    }
  }
  
  func fetchInitialResults(with location: CLLocation) {
    self.hasSubmittedInitialQuery = true
    self.appContext.apiClient.requestNearbyRestaurants(for: location) { (maybeResult, maybeError) in
      if let result = maybeResult {
        self.renderLocations(in: result)
      }
    }
  }
  
  func presentLocationDisabledAlert(with message: String) {
    let alertController = UIAlertController(
      title: "Location services disabled",
      message: message,
      preferredStyle: UIAlertController.Style.alert)
    
    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
    
    self.present(alertController, animated: true)
  }
  
  func setMapViewPort(to location: CLLocation) {
    let mapPoints = 1500 * MKMapPointsPerMeterAtLatitude(location.coordinate.latitude)
    let mapRect = MKMapRect(origin: MKMapPoint(location.coordinate), size: MKMapSize(width: mapPoints, height: mapPoints))
    let centeredMapRect = mapRect.offsetBy(dx: -mapPoints / 2, dy: -mapPoints / 2)
    self.mapView.setVisibleMapRect(centeredMapRect, animated: true)
  }
  
  func renderLocations(in result: RestaurantsResult) {
    // todo clear existing
    mapView.removeAnnotations(currentAnnotations)
    currentAnnotations = []
    currentAnnotations = result.results.compactMap({ (restaurant) -> MKAnnotation? in
      if let location = restaurant.clLocation2D() {
        let it = MKPointAnnotation()
        it.coordinate = location
        return it
//        let placemark = MKPlacemark(coordinate: location)
//        return placemark
      }
      return nil
    })

    mapView.addAnnotations(currentAnnotations)
  }
  
}

extension MapResultsViewController: ApplicationContextDelegate {
  
  func didUpdateLocation(to location: CLLocation) {
    if !hasSubmittedInitialQuery {
      self.fetchInitialResults(with: location)
      self.setMapViewPort(to: location)
    }
  }
  
}
