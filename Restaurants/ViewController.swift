//
//  ViewController.swift
//  Restaurants
//
//  Created by Clay on 12/11/18.
//  Copyright © 2018 clay. All rights reserved.
//

import UIKit
import CoreLocation

class MapResultsViewController: UIViewController {
  
  let appContext: ApplicationContext
  var hasSubmittedInitialQuery = false
  
  required init?(coder aDecoder: NSCoder) {
    appContext = ApplicationContext()

    super.init(coder: aDecoder)
    
    self.appContext.delegate = self
  }
//  
//  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//    appContext = ApplicationContext()
//    
//    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    
//    self.appContext.delegate = self
//  }
  
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
    self.appContext.apiClient.requestRestaurants(with: nil, location: location) {
      // todo
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

}

extension MapResultsViewController: ApplicationContextDelegate {
  
  func didUpdateLocation(location: CLLocation) {
    if !hasSubmittedInitialQuery {
      self.fetchInitialResults(with: location)
    }
  }
  
}
