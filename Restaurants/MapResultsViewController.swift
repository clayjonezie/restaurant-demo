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

// Root view controller consisting of the searchbar, results view toggle, and map or list results view.
class MapResultsViewController: UIViewController {
  
  let appContext: ApplicationContext
  var hasSubmittedInitialQuery = false
  var userLocationMarkerView: MKMarkerAnnotationView?
  var currentAnnotations: [MKAnnotation]
  var currentResult: RestaurantsResult?
  var resultsTableViewController: ResultsTableViewController?
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var resultsOnMapSwitch: UISwitch!
  
  required init?(coder aDecoder: NSCoder) {
    appContext = ApplicationContext()
    self.currentAnnotations = []
    self.currentResult = nil
    
    super.init(coder: aDecoder)
    
    self.appContext.delegate = self
  }
  
  override func viewDidLoad() {
    self.mapView.showsUserLocation = true
    self.mapView.userLocation.title = nil
    self.mapView.delegate = self
    self.searchBar.delegate = self
    self.resultsOnMapSwitch.setOn(true, animated: false)
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
        self.renderLocationsOnMap(in: result)
      } else {
        self.presentNetworkErrorAlert()
      }
    }
  }
  
  func fetchSearchResults(with keyword: String) {
    if let userLocation = self.mapView.userLocation.location {
      self.appContext.apiClient.requestNearbyRestaurants(for: userLocation, keyword: keyword) { (maybeResult, maybeError) in
        if let result = maybeResult {
          if self.resultsOnMapSwitch.isOn {
            self.renderLocationsOnMap(in: result)
          } else {
            self.renderLocationsInTableView(in: result)
          }
        } else {
          self.presentNetworkErrorAlert()
        }
      }
    } else {
      self.presentLocationDisabledAlert(with: "Unable to determine current location.")
    }
  }
  
  func setMapViewPort(to location: CLLocation) {
    let mapPoints = Double(ApiClient.Constant.defaultRadius) * MKMapPointsPerMeterAtLatitude(location.coordinate.latitude)
    let mapRect = MKMapRect(origin: MKMapPoint(location.coordinate), size: MKMapSize(width: mapPoints, height: mapPoints))
    let centeredMapRect = mapRect.offsetBy(dx: -mapPoints / 2, dy: -mapPoints / 2)
    self.mapView.setVisibleMapRect(centeredMapRect, animated: true)
  }
  
  func renderLocationsOnMap(in result: RestaurantsResult) {
    if let resultsTableViewController = self.resultsTableViewController {
      resultsTableViewController.view.removeFromSuperview()
      self.resultsTableViewController = nil
    }
    
    self.mapView.removeAnnotations(currentAnnotations)
    self.currentAnnotations = []
    self.currentResult = result
    
    self.currentAnnotations = result.results.compactMap({ (restaurant) -> MKAnnotation? in
      if let location = restaurant.clLocation2D() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        return annotation
      }
      return nil
    })
    
    mapView.addAnnotations(currentAnnotations)
  }
  
  func renderLocationsInTableView(in result: RestaurantsResult) {
    // avoid stale results after toggling switch
    self.mapView.removeAnnotations(currentAnnotations)
    self.currentAnnotations = []
    self.currentResult = result
    
    if let existingResultsViewController = self.resultsTableViewController {
      existingResultsViewController.update(with: result)
    } else {
      let newResultsViewController = ResultsTableViewController(result: result)
      newResultsViewController.delegate = self
      newResultsViewController.view.translatesAutoresizingMaskIntoConstraints = false
      self.view.addSubview(newResultsViewController.view)
      self.view.bringSubviewToFront(newResultsViewController.view)
      let constraints = [
        newResultsViewController.view.topAnchor.constraint(equalTo: self.mapView.topAnchor),
        newResultsViewController.view.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor),
        newResultsViewController.view.leftAnchor.constraint(equalTo: self.mapView.leftAnchor),
        newResultsViewController.view.rightAnchor.constraint(equalTo: self.mapView.rightAnchor)
      ]
      NSLayoutConstraint.activate(constraints)
      self.resultsTableViewController = newResultsViewController
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
  
  func presentNetworkErrorAlert() {
    let alertController = UIAlertController(
      title: "Network error",
      message: "There was an issue with the network, or with Google's API.",
      preferredStyle: UIAlertController.Style.alert)
    
    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
    
    self.present(alertController, animated: true)
  }
  
  func presentDetails(for restaurant: Restaurant) {
    let alert = UIAlertController(
      title: restaurant.name,
      message: restaurant.formattedDescription(),
      preferredStyle: UIAlertController.Style.actionSheet)
    
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (_) in
      self.deselectAllAnnotations()
    })
    self.present(alert, animated: true)
  }
  
  func deselectAllAnnotations() {
    self.mapView.selectedAnnotations.forEach { (annotation) in
      self.mapView.deselectAnnotation(annotation, animated: true)
    }
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

extension MapResultsViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let text = searchBar.text, text.count > 0 {
      self.fetchSearchResults(with: text)
    }
    searchBar.resignFirstResponder()
  }
  
}

extension MapResultsViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let index = self.currentAnnotations.firstIndex(where: { (annotation) -> Bool in
      return view.annotation?.hash == annotation.hash
    }), let currentResults = self.currentResult, index < currentResults.results.count {
      self.presentDetails(for: currentResults.results[index])
    }
  }
  
}

extension MapResultsViewController: ResultsTableViewControllerDelegate {
  
  func resultsTableViewControllerDidSelect(restaurant: Restaurant) {
    self.presentDetails(for: restaurant)
  }
  
}
